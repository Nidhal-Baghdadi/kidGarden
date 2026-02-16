class NotificationService
  def self.send_attendance_notification(attendance_record)
    # Find parents of the student
    student = attendance_record.student
    parents = []
    
    # Add the direct parent if exists
    parents << student.parent if student.parent.present?
    
    # Add all associated parents through parent_student_relationships
    parents += student.all_parents if student.all_parents.any?
    
    # Send notification to each parent
    parents.uniq.each do |parent|
      NotificationMailer.attendance_notification(parent, attendance_record).deliver_later
    end
    
    # Also notify teachers of the classroom
    if student.classroom&.teacher.present?
      teacher = student.classroom.teacher
      NotificationMailer.attendance_notification(teacher, attendance_record).deliver_later
    end
  end

  def self.send_fee_notification(fee_record)
    # Find parents of the student
    student = fee_record.student
    parents = []
    
    # Add the direct parent if exists
    parents << student.parent if student.parent.present?
    
    # Add all associated parents through parent_student_relationships
    parents += student.all_parents if student.all_parents.any?
    
    # Send notification to each parent
    parents.uniq.each do |parent|
      NotificationMailer.fee_notification(parent, fee_record).deliver_later
    end
  end

  def self.send_event_notification(event_record)
    # Get all users who should receive event notifications
    recipients = []
    
    # Add all users based on event type or audience
    # For now, we'll send to all active parents and teachers
    recipients += User.where(role: %w[parent teacher], status: :active)
    
    # Exclude the organizer if they don't want their own event notifications
    recipients -= [event_record.organizer] if event_record.organizer
    
    # Send notification to all recipients
    NotificationMailer.event_notification(recipients, event_record).deliver_later if recipients.any?
  end

  def self.send_daily_summary
    # Get all active users who should receive daily summaries
    recipients = User.where(status: :active, role: %w[parent teacher admin staff])
    
    recipients.each do |recipient|
      summary_data = {
        attendance_stats: get_daily_attendance_stats,
        events_today: get_daily_events,
        new_notifications: get_new_notifications,
        fees_due: get_upcoming_fees
      }
      
      NotificationMailer.daily_summary_email(recipient, summary_data).deliver_later
    end
  end

  private

  def self.get_daily_attendance_stats
    # Calculate attendance statistics for today
    present_count = Attendance.where(date: Date.current, status: :present).count
    absent_count = Attendance.where(date: Date.current, status: :absent).count
    
    { present: present_count, absent: absent_count }
  end

  def self.get_daily_events
    # Get events happening today
    Event.where(start_time: Date.current.beginning_of_day..Date.current.end_of_day)
  end

  def self.get_new_notifications
    # Get notifications created today
    Notification.where(created_at: Date.current.beginning_of_day..Date.current.end_of_day)
  end

  def self.get_upcoming_fees
    # Get fees due within the next week
    Fee.where(due_date: Date.current..1.week.from_now)
  end
end