class AttendanceNotificationJob < ApplicationJob
  queue_as :default

  def perform(student_id, date, status)
    student = Student.find(student_id)
    parent_ids = student.parent_student_relationships.pluck(:parent_id)
    
    parent_ids.each do |parent_id|
      Notification.create!(
        title: "Attendance Update for #{student.first_name} #{student.last_name}",
        message: "Your child was marked as #{status.humanize.downcase} on #{date.strftime('%B %d, %Y')}",
        recipient_type: 'User',
        recipient_id: parent_id,
        sender_id: nil, # System notification
        notification_type: :attendance
      )
    end
    
    # Also send email notification if needed
    # AttendanceNotificationMailer.send_notification(student, date, status).deliver_later
  end
end