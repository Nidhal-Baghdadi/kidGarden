class Payment < ApplicationRecord
  belongs_to :fee
  belongs_to :student, optional: true
  belongs_to :created_by, class_name: 'User', optional: true

  enum :payment_method, { cash: 0, bank_transfer: 1, check: 2, credit_card: 3, online: 4 }
  enum :status, { pending: 0, completed: 1, failed: 2, refunded: 3 }

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :payment_date, presence: true
  validates :payment_method, presence: true

  before_save :update_fee_status

  def update_fee_status
    if completed?
      # Update the associated fee status to paid
      fee.update(status: :paid) if fee
    end
  end

  def refund!
    update(status: :refunded)
    # Update the associated fee status back to pending
    fee.update(status: :pending) if fee
  end

  def transaction_reference
    "#{fee.id}-#{id}-#{payment_date.strftime('%Y%m%d')}"
  end

  def payment_method_label
    case payment_method
    when 'cash'
      'Cash'
    when 'bank_transfer'
      'Bank Transfer'
    when 'check'
      'Check'
    when 'credit_card'
      'Credit Card'
    when 'online'
      'Online Payment'
    else
      'Unknown'
    end
  end

  def status_label
    case status
    when 'pending'
      'Pending'
    when 'completed'
      'Completed'
    when 'failed'
      'Failed'
    when 'refunded'
      'Refunded'
    else
      'Unknown'
    end
  end
end