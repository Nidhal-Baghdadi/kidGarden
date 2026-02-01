class EventNotificationJob < ApplicationJob
  queue_as :default

  def perform(event_id)
    event = Event.find(event_id)
    
    # Notify all parents
    parent_ids = User.where(role: :parent).pluck(:id)
    
    parent_ids.each do |parent_id|
      Notification.create!(
        title: "New Event: #{event.title}",
        message: "An event is scheduled for #{event.start_time.strftime('%B %d, %Y at %I:%M %p')}. Location: #{event.location}. #{event.description}",
        recipient_type: 'User',
        recipient_id: parent_id,
        sender_id: event.organizer_id,
        notification_type: :event
      )
    end

    # Also send email notification if needed
    # EventNotificationMailer.send_notification(event).deliver_later
  end
end