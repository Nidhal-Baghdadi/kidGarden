class NotificationService
  def self.send_notification(recipient:, title:, message:, notification_type: 'general', sender: nil, link: nil)
    Notification.create!(
      recipient: recipient,
      title: title,
      message: message,
      notification_type: notification_type,
      sender: sender,
      link: link
    )
  end

  def self.send_attendance_notification(student:, status:, date:, teacher:)
    title = "Attendance Update for #{student.first_name} #{student.last_name}"
    message = "Your child was marked as #{status.humanize.downcase} on #{date.strftime('%B %d, %Y')}."

    # Find all parents of the student
    parents = student.all_parents
    parents.each do |parent|
      send_notification(
        recipient: parent,
        title: title,
        message: message,
        notification_type: 'attendance',
        sender: teacher,
        link: Rails.application.routes.url_helpers.student_path(student)
      )
    end
  end

  def self.send_fee_notification(student:, fee:, amount:, due_date:)
    title = "Fee Due: #{fee.description || 'School Fee'}"
    message = "A fee of #{amount} TND is due on #{due_date.strftime('%B %d, %Y')} for #{student.first_name} #{student.last_name}."

    parents = student.all_parents
    parents.each do |parent|
      send_notification(
        recipient: parent,
        title: title,
        message: message,
        notification_type: 'fee',
        sender: nil, # System notification
        link: Rails.application.routes.url_helpers.fees_path
      )
    end
  end

  def self.send_event_notification(event:, recipients: nil)
    title = "New Event: #{event.title}"
    message = "#{event.description}\n\nDate: #{event.start_time.strftime('%B %d, %Y at %I:%M %p')}"

    # If no recipients specified, notify all parents
    recipients ||= User.where(role: :parent)

    recipients.each do |recipient|
      send_notification(
        recipient: recipient,
        title: title,
        message: message,
        notification_type: 'event',
        sender: event.organizer,
        link: Rails.application.routes.url_helpers.event_path(event)
      )
    end
  end

  def self.send_daily_summary(parent:, date: Date.current)
    # Find all students associated with this parent
    students = parent.students_as_parent
    return if students.empty?

    # Find attendance records for their children today
    attendance_records = Attendance.joins(:student)
                                  .where(students: { id: students.ids }, date: date)
                                  .includes(:student)

    if attendance_records.any?
      title = "Daily Summary for #{date.strftime('%B %d, %Y')}"
      message = "Attendance updates for your children:\n"
      
      attendance_records.each do |attendance|
        message += "- #{attendance.student.first_name}: #{attendance.status.humanize}\n"
      end

      send_notification(
        recipient: parent,
        title: title,
        message: message,
        notification_type: 'daily_summary',
        sender: nil, # System notification
        link: Rails.application.routes.url_helpers.attendances_path
      )
    end
  end

  def self.send_new_message_notification(message)
    # Notify recipient about new message
    send_notification(
      recipient: message.recipient,
      title: "New Message from #{message.sender.name}",
      message: message.content.truncate(100),
      notification_type: 'message',
      sender: message.sender,
      link: Rails.application.routes.url_helpers.conversation_messages_path(message.conversation)
    )
  end
end