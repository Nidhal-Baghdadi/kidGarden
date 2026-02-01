class FeeNotificationJob < ApplicationJob
  queue_as :default

  def perform(fee_id)
    fee = Fee.find(fee_id)
    student = fee.student
    parent_ids = student.parent_student_relationships.pluck(:parent_id)
    
    parent_ids.each do |parent_id|
      Notification.create!(
        title: "Fee Due: #{fee.description}",
        message: "A fee of #{number_to_currency(fee.amount)} is due on #{fee.due_date.strftime('%B %d, %Y')}. Status: #{fee.status.humanize}",
        recipient_type: 'User',
        recipient_id: parent_id,
        sender_id: nil, # System notification
        notification_type: :fee
      )
    end
    
    # Also send email notification if needed
    # FeeNotificationMailer.send_notification(fee).deliver_later
  end
  
  private
  
  def number_to_currency(amount)
    ActionController::Base.helpers.number_to_currency(amount)
  end
end