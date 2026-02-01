class Message < ApplicationRecord
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, class_name: 'User'
  belongs_to :conversation
  has_many :message_read_receipts, dependent: :destroy
  has_many_attached :attachments

  validates :content, presence: true
  validates :sender_id, presence: true
  validates :recipient_id, presence: true
  validates :conversation_id, presence: true

  enum :message_type, { text: 0, image: 1, document: 2, multimedia: 3 }

  scope :recent, -> { order(created_at: :desc) }
  scope :by_sender, ->(user) { where(sender: user) }
  scope :by_recipient, ->(user) { where(recipient: user) }

  after_create_commit -> {
    broadcast_message
    send_notification
  }

  def read_status_for_user(user)
    message_read_receipts.find_by(user: user)&.read_at
  end

  private

  def send_notification
    # Send notification to recipient about the new message
    NotificationService.send_new_message_notification(self)
  end

  def unread_for_user?(user)
    read_status_for_user(user).nil?
  end

  def read_by_user?(user)
    !unread_for_user?(user)
  end

  def mark_as_read_by(user)
    message_read_receipts.find_or_create_by(user: user, read_at: Time.current)
  end

  private

  def broadcast_message
    # Broadcast to recipient using ActionCable if available
    # This would trigger real-time updates for the recipient
    MessageBroadcastJob.perform_later(self)
  end
end