class MessageReadReceipt < ApplicationRecord
  belongs_to :message
  belongs_to :user

  validates :message_id, uniqueness: { scope: :user_id }
end