class ConversationsController < ApplicationController
  before_action :authenticate_user!

  def index
    # Get all conversations the current user is part of
    @conversations = Conversation.joins(:conversation_participants)
                                .where(conversation_participants: { user_id: current_user.id })
                                .order('conversations.last_activity_at DESC NULLS LAST')

    # Get unread counts for each conversation
    @unread_counts = {}
    @conversations.each do |conversation|
      @unread_counts[conversation.id] = conversation.unread_count_for(current_user)
    end

    render template: 'messages/conversations'
  end

  def show
    begin
      @conversation = Conversation.find(params[:id])

      # Verify that the current user is a participant in this conversation
      unless @conversation.participants.include?(current_user)
        redirect_to user_conversations_path, alert: "You don't have access to this conversation."
        return
      end

      @messages = @conversation.messages.includes(:sender, :recipient).order(:created_at)
      @message = Message.new
    rescue ActiveRecord::RecordNotFound
      redirect_to user_conversations_path, alert: "Conversation not found."
    end
  end

  def create
    begin
      recipient = User.find(params[:recipient_id])

      # Check if a conversation already exists between these users
      @conversation = Conversation.between(current_user, recipient)

      redirect_to conversation_messages_path(@conversation)
    rescue ActiveRecord::RecordNotFound
      redirect_to user_conversations_path, alert: "Recipient not found."
    end
  end
end