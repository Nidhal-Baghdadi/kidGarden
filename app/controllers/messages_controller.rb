class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation, only: [:index, :create]
  before_action :set_message, only: [:show, :destroy]

  # GET /conversations/:conversation_id/messages
  def index
    return unless @conversation

    @messages =
      @conversation
        .messages
        .includes(:sender, :recipient, :message_read_receipts, attachments_attachments: :blob)
        .order(:created_at)

    @message = Message.new

    mark_conversation_messages_as_read!(@conversation)
  end

  # POST /conversations/:conversation_id/messages
  def create
    return unless @conversation

    @message = @conversation.messages.build(message_params)
    @message.sender = current_user
    @message.recipient = determine_recipient

    unless @message.recipient
      redirect_to conversation_messages_path(@conversation), alert: "Recipient not found for this conversation."
      return
    end

    if @message.save
      # Set delivered_at if that column exists (no assumptions)
      if @message.has_attribute?(:delivered_at) && @message.delivered_at.blank?
        @message.update(delivered_at: Time.current)
      end

      if @conversation.has_attribute?(:last_activity_at)
        @conversation.update(last_activity_at: Time.current)
      else
        @conversation.touch
      end

      redirect_to conversation_messages_path(@conversation), notice: "Message sent successfully."
    else
      @messages =
        @conversation
          .messages
          .includes(:sender, :recipient, :message_read_receipts, attachments_attachments: :blob)
          .order(:created_at)

      render :index, status: :unprocessable_entity
    end
  end

  # GET /messages/:id
  def show
    return unless @message

    unless @message.conversation.participants.include?(current_user)
      redirect_to user_conversations_path, alert: "You don't have access to this message."
      return
    end

    mark_message_as_read!(@message) if @message.recipient_id == current_user.id
  end

  # DELETE /messages/:id
  def destroy
    return unless @message

    unless @message.conversation.participants.include?(current_user)
      redirect_to user_conversations_path, alert: "You don't have access to this message."
      return
    end

    unless current_user.admin? || @message.sender_id == current_user.id
      redirect_back fallback_location: user_conversations_path,
                    alert: "You don't have permission to delete this message."
      return
    end

    conversation = @message.conversation
    @message.destroy
    redirect_to conversation_messages_path(conversation), notice: "Message was successfully deleted."
  end

  # GET /conversations  (named route: user_conversations)
  def conversations
    @conversations =
      Conversation
        .joins(:conversation_participants)
        .where(conversation_participants: { user_id: current_user.id })
        .includes(:participants)
        .order(Arel.sql("conversations.last_activity_at DESC NULLS LAST, conversations.updated_at DESC"))

    ids = @conversations.pluck(:id)

    # Unread = messages to me in those convos that do NOT have a receipt for me
    read_message_ids = MessageReadReceipt.where(user_id: current_user.id).select(:message_id)

    @unread_counts =
      if ids.empty?
        {}
      else
        Message
          .where(conversation_id: ids, recipient_id: current_user.id)
          .where.not(sender_id: current_user.id)
          .where.not(id: read_message_ids)
          .group(:conversation_id)
          .count
      end
  end

  # GET /conversations/new (named route: new_user_conversation)
  def new_conversation
    @recipients = determine_available_recipients.order(:name)

    unless @recipients.any?
      redirect_to user_conversations_path, alert: "No available recipients to message."
      return
    end
  end

  # POST /start_conversation
  def start_conversation
    recipient = determine_available_recipients.find_by(id: params[:recipient_id])

    unless recipient
      redirect_to user_conversations_path, alert: "Recipient not found or not allowed."
      return
    end

    conversation = Conversation.between(current_user, recipient)

    unless conversation&.persisted?
      redirect_to user_conversations_path, alert: "Failed to create conversation."
      return
    end

    redirect_to conversation_messages_path(conversation)
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:conversation_id] || params[:id])

    unless @conversation.participants.include?(current_user)
      redirect_to user_conversations_path, alert: "You don't have access to this conversation."
      @conversation = nil
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to user_conversations_path, alert: "Conversation not found."
    @conversation = nil
  end

  def set_message
    @message = Message.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to user_conversations_path, alert: "Message not found."
    @message = nil
  end

  def message_params
    # Your model uses has_many_attached :attachments
    params.require(:message).permit(:content, :message_type, attachments: [])
  end

  def determine_recipient
    @conversation.other_participant(current_user)
  end

  # ===== Read receipt helpers (receipt-based, consistent with your models) =====

  def mark_message_as_read!(message)
    attrs = { message_id: message.id, user_id: current_user.id }
    now = Time.current

    attrs[:read_at] = now if MessageReadReceipt.column_names.include?("read_at")
    attrs[:created_at] = now if MessageReadReceipt.column_names.include?("created_at")
    attrs[:updated_at] = now if MessageReadReceipt.column_names.include?("updated_at")

    # Avoid duplicate receipt (unique validation)
    MessageReadReceipt.insert_all([attrs], unique_by: %i[message_id user_id]) if MessageReadReceipt.respond_to?(:insert_all)

    # Optional: if your messages table has read_at and you still want it filled, do it only if present
    if message.has_attribute?(:read_at) && message.read_at.blank?
      message.update(read_at: now)
    end
  rescue ActiveRecord::RecordNotUnique
    # receipt already exists
  end

  def mark_conversation_messages_as_read!(conversation)
    # Mark only messages addressed to me
    message_ids =
      conversation
        .messages
        .where(recipient_id: current_user.id)
        .pluck(:id)

    return if message_ids.empty?

    # Only for those without a receipt for me already
    already_read_ids =
      MessageReadReceipt
        .where(user_id: current_user.id, message_id: message_ids)
        .pluck(:message_id)

    unread_ids = message_ids - already_read_ids
    return if unread_ids.empty?

    now = Time.current
    rows = unread_ids.map do |mid|
      row = { message_id: mid, user_id: current_user.id }
      row[:read_at] = now if MessageReadReceipt.column_names.include?("read_at")
      row[:created_at] = now if MessageReadReceipt.column_names.include?("created_at")
      row[:updated_at] = now if MessageReadReceipt.column_names.include?("updated_at")
      row
    end

    if MessageReadReceipt.respond_to?(:insert_all)
      MessageReadReceipt.insert_all(rows, unique_by: %i[message_id user_id])
    else
      # fallback (older Rails)
      rows.each do |r|
        MessageReadReceipt.find_or_create_by(message_id: r[:message_id], user_id: r[:user_id]) do |rec|
          rec.read_at = r[:read_at] if rec.respond_to?(:read_at) && r.key?(:read_at)
        end
      end
    end
  rescue ActiveRecord::RecordNotUnique
    # race creating receipts — safe to ignore
  end

  # ===== Recipient rules (your logic, cleaned but not changed in meaning) =====

  def determine_available_recipients
    case current_user.role
    when "parent"
      classroom_ids =
        current_user.students_as_parent
                    .where.not(classroom_id: nil)
                    .distinct
                    .pluck(:classroom_id)

      return User.none if classroom_ids.empty?

      User.where(role: "teacher")
          .joins(:classrooms_taught)
          .where(classrooms: { id: classroom_ids })
          .where.not(id: current_user.id)
          .distinct

    when "teacher"
      return User.none unless current_user.classrooms_taught.exists?

      student_ids =
        current_user.classrooms_taught
                    .joins(:students)
                    .distinct
                    .pluck("students.id")

      return User.none if student_ids.empty?

      User.where(role: "parent")
          .joins(:students_as_parent)
          .where(students: { id: student_ids })
          .where.not(id: current_user.id)
          .distinct

    when "admin"
      User.where.not(id: current_user.id)

    else
      User.none
    end
  rescue StandardError
    User.none
  end
end
