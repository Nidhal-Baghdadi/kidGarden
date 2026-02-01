class Notification < ApplicationRecord
  belongs_to :sender, class_name: 'User', optional: true
  belongs_to :recipient, class_name: 'User', optional: true

  enum :notification_type, { general: 0, attendance: 1, fee: 2, event: 3, alert: 4 }

  validates :title, :message, :recipient_type, presence: true
  validates :recipient_id, presence: true
end
