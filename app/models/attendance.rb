class Attendance < ApplicationRecord
  include EmailNotification

  belongs_to :student
  belongs_to :staff, class_name: 'User', optional: true

  enum :status, { present: 0, absent: 1, late: 2, excused: 3 }

  validates :date, presence: true
  validates :student_id, presence: true
  validates :status, presence: true
  validates :student_id, uniqueness: { scope: :date }

  after_commit :send_notification, on: [:create, :update]

  private

  def send_notification
    send_attendance_notification_async
  end
end
