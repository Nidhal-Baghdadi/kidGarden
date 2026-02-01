class Conversation < ApplicationRecord
  belongs_to :creator, class_name: 'User', optional: true
  has_many :messages, dependent: :destroy
  has_many :conversation_participants, dependent: :destroy
  has_many :participants, through: :conversation_participants, source: :user
  has_many :message_read_receipts, dependent: :destroy

  validates :subject, presence: true

  scope :between_users, ->(user1, user2) { 
    joins(:conversation_participants).where(conversation_participants: { user: [user1, user2] })
    .group('conversations.id')
    .having('COUNT(DISTINCT conversation_participants.user_id) = 2')
  }

  def participant_names
    begin
      participants.map(&:name).join(', ')
    rescue ActiveRecord::RecordNotFound
      # Handle case where participant records don't exist
      "Participants with missing records"
    end
  end

  def unread_count_for(user)
    begin
      messages.joins('LEFT JOIN message_read_receipts ON messages.id = message_read_receipts.message_id AND message_read_receipts.user_id = ?', user.id)
             .where('message_read_receipts.read_at IS NULL')
             .where.not(sender: user)
             .count
    rescue ActiveRecord::RecordNotFound
      0
    end
  end

  def last_message
    begin
      messages.order(:created_at).last
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end

  def other_participant(current_user)
    begin
      participants.where.not(id: current_user.id).first
    rescue ActiveRecord::RecordNotFound
      # Handle case where participant records don't exist
      nil
    end
  end

  def self.between(user1, user2)
    # Find or create a conversation between two users
    begin
      # Verify both users exist before proceeding
      unless user1 && user2
        Rails.logger.warn "One or both users are nil in Conversation.between"
        return nil
      end

      # Verify users are valid records
      unless user1.persisted? && user2.persisted?
        Rails.logger.warn "One or both users are not persisted records in Conversation.between"
        return nil
      end

      conversation = Conversation.joins(:conversation_participants)
                                .where(conversation_participants: { user: [user1, user2] })
                                .group('conversations.id')
                                .having('COUNT(DISTINCT conversation_participants.user_id) = 2')
                                .first

      if conversation
        conversation
      else
        new_conversation = nil
        ActiveRecord::Base.transaction do
          # Safely get user names, falling back to IDs if name is unavailable
          user1_name = user1.name.present? ? user1.name : "User #{user1.id}"
          user2_name = user2.name.present? ? user2.name : "User #{user2.id}"

          new_conversation = create!(
            subject: "Conversation between #{user1_name} and #{user2_name}",
            creator: user1
          )

          # Verify users still exist before creating associations
          if user1.persisted?
            new_conversation.conversation_participants.create!(user: user1)
          else
            raise ActiveRecord::RecordNotFound, "User #{user1.id} not found"
          end

          if user2.persisted?
            new_conversation.conversation_participants.create!(user: user2)
          else
            raise ActiveRecord::RecordNotFound, "User #{user2.id} not found"
          end
        end
        new_conversation
      end
    rescue ActiveRecord::RecordNotFound, ActiveRecord::StatementInvalid => e
      Rails.logger.error "Error in Conversation.between: #{e.message}"
      # Handle case where referenced records don't exist
      nil
    end
  end
end