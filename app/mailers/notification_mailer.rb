class NotificationMailer < ApplicationMailer
  default from: "notifications@kidgarden.com"

  def attendance_notification(recipient, attendance_record)
    @recipient = recipient
    @attendance = attendance_record
    @student = @attendance.student
    @classroom = @attendance.student.classroom
    
    mail(
      to: @recipient.email,
      subject: "Attendance Update for #{@student.full_name}"
    )
  end

  def fee_notification(recipient, fee_record)
    @recipient = recipient
    @fee = fee_record
    @student = @fee.student
    
    mail(
      to: @recipient.email,
      subject: "New Fee Assessment for #{@student.full_name}"
    )
  end

  def event_notification(recipients, event)
    @recipients = recipients
    @event = event
    @organizer = @event.organizer
    
    mail(
      to: @recipients.map(&:email).join(', '),
      subject: "New Event: #{@event.title}"
    )
  end

  def daily_summary_email(recipient, summary_data)
    @recipient = recipient
    @summary = summary_data
    
    mail(
      to: @recipient.email,
      subject: "Daily Summary - #{Date.today.strftime('%B %d, %Y')}"
    )
  end
end