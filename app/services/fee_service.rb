# Service object for handling fee processing
class FeeService
  def initialize(student:, amount:, due_date:, description: nil, receipt_number: nil)
    @student = student
    @amount = amount
    @due_date = due_date
    @description = description
    @receipt_number = receipt_number
  end

  def create_fee!
    ActiveRecord::Base.transaction do
      fee = Fee.create!(
        student: @student,
        amount: @amount,
        due_date: @due_date,
        description: @description,
        receipt_number: @receipt_number,
        status: :pending
      )
      
      # Enqueue notification job
      FeeNotificationJob.perform_later(fee.id)
      
      fee
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Failed to create fee for student #{@student.id}: #{e.message}"
    raise e
  end
  
  def self.mark_as_paid(fee_id)
    fee = Fee.find(fee_id)
    
    ActiveRecord::Base.transaction do
      fee.update!(status: :paid)
      
      # Could add additional logic here, like sending receipts, etc.
      fee
    end
  end
  
  def self.send_overdue_reminders
    overdue_fees = Fee.where(status: :pending).where('due_date < ?', Date.current)
    
    overdue_fees.find_each do |fee|
      # In a real app, we might send a reminder email/notification
      FeeNotificationJob.perform_later(fee.id)
    end
  end
end