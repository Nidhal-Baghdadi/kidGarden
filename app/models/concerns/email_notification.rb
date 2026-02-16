module EmailNotification
  extend ActiveSupport::Concern

  def send_attendance_notification_async
    NotificationService.send_attendance_notification(self)
  end

  def send_fee_notification_async
    NotificationService.send_fee_notification(self)
  end

  def send_event_notification_async
    NotificationService.send_event_notification(self)
  end
end