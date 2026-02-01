class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation, only: [:index, :create]
  before_action :set_message, only: [:show, :destroy]

  # GET /conversations/:conversation_id/messages
  def index
    @messages = @conversation.messages.includes(:sender, :recipient).order(:created_at)
    @message = Message.new
  end

  # POST /conversations/:conversation_id/messages
  def create
    @message = @conversation.messages.build(message_params)
    @message.sender = current_user
    @message.recipient = determine_recipient

    if @message.save
      # Mark as delivered
      @message.update(delivered_at: Time.current)
      
      redirect_to conversation_messages_path(@conversation), notice: 'Message sent successfully.'
    else
      @messages = @conversation.messages.includes(:sender, :recipient).order(:created_at)
      render :index
    end
  end

  # GET /messages/:id
  def show
    # Mark message as read if it's for the current user
    if @message.recipient == current_user && !@message.read_at
      @message.update(read_at: Time.current)
      @message.message_read_receipts.create(user: current_user, read_at: Time.current) if @message.message_read_receipts.none? { |r| r.user == current_user }
    end
  end

  # DELETE /messages/:id
  def destroy
    @message.destroy
    redirect_to conversation_messages_path(@message.conversation), notice: 'Message was successfully deleted.'
  end

  # GET /conversations
  def conversations
    begin
      # Get all conversations the current user is part of
      @conversations = Conversation.joins(:conversation_participants)
                                  .where(conversation_participants: { user_id: current_user.id })
                                  .includes(:participants, :messages)  # Eager load associations to avoid N+1 queries
                                  .order('conversations.last_activity_at DESC NULLS LAST')

      # Get unread counts for each conversation
      @unread_counts = {}
      @conversations.each do |conversation|
        # Skip conversations that have missing associations
        begin
          @unread_counts[conversation.id] = conversation.unread_count_for(current_user)
        rescue ActiveRecord::RecordNotFound
          # Skip conversation if it has missing associated records
          @unread_counts[conversation.id] = 0
        end
      end
    rescue ActiveRecord::RecordNotFound => e
      redirect_to user_conversations_path, alert: "Error accessing conversation data: #{e.message}"
    end
  end

  # GET /new_conversation
  def new_conversation
    puts "Are we here?"
    begin
      @recipients = determine_available_recipients

      # Check if user has any available recipients to message
      unless @recipients.any?
        redirect_to user_conversations_path, alert: "No available recipients to message."
        return
      end
    rescue StandardError => e
      redirect_to user_conversations_path, alert: "Error accessing conversation data: #{e.message}"
      return
    end

    # Render the new conversation form
    render :new_conversation
  end

  # POST /start_conversation
  def start_conversation
    recipient = User.find_by(id: params[:recipient_id])

    unless recipient
      redirect_to user_conversations_path, alert: "Recipient not found."
      return
    end

    # Check if a conversation already exists between these users
    conversation = Conversation.between(current_user, recipient)

    # Ensure conversation was created successfully and is valid
    unless conversation && conversation.persisted?
      redirect_to user_conversations_path, alert: "Failed to create conversation."
      return
    end

    redirect_to conversation_messages_path(conversation)
  end

  private

  def set_conversation
    begin
      @conversation = Conversation.find(params[:conversation_id] || params[:id])

      # Verify that the current user is a participant in this conversation
      unless @conversation.participants.include?(current_user)
        redirect_to conversations_path, alert: "You don't have access to this conversation."
      end
    rescue ActiveRecord::RecordNotFound
      redirect_to user_conversations_path, alert: "Conversation not found."
    end
  end

  def set_message
    begin
      @message = Message.find(params[:id])

      # Verify that the current user is part of the conversation
      unless @message.conversation.participants.include?(current_user)
        redirect_to conversations_path, alert: "You don't have access to this message."
      end
    rescue ActiveRecord::RecordNotFound
      redirect_to user_conversations_path, alert: "Message not found."
    end
  end

  def message_params
    params.require(:message).permit(:content, :message_type, :attachment)
  end

  def determine_recipient
    # For private conversations, recipient is the other participant
    @conversation.other_participant(current_user)
  end

  def determine_available_recipients
    case current_user.role
    when 'parent'
      # Parents can message teachers of their children's classrooms
      begin
        # Get classroom IDs for the parent's students, ensuring they exist
        student_classroom_ids = current_user.students_as_parent.exists? ? current_user.students_as_parent.pluck(:classroom_id).compact : []
        if student_classroom_ids.any?
          # Find teachers associated with those classrooms
          User.where(role: 'teacher').joins(:classrooms_taught).where(classrooms: { id: student_classroom_ids }).distinct
        else
          User.none
        end
      rescue StandardError
        User.none
      end
    when 'teacher'
      # Teachers can message parents of students in their classrooms
      begin
        # Get student IDs from the teacher's classrooms, ensuring they exist
        if current_user.classrooms_taught.exists?
          classroom_student_ids = current_user.classrooms_taught.joins(:students).pluck('students.id').uniq
          # Find parents of those students
          User.where(role: 'parent').joins(:students_as_parent).where(students: { id: classroom_student_ids }).distinct
        else
          User.none
        end
      rescue StandardError
        User.none
      end
    when 'admin'
      # Admins can message anyone
      User.where.not(id: current_user.id)
    else
      # Other roles can't initiate conversations
      User.none
    end
  end
end