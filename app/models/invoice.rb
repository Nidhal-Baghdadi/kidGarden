class Invoice < ApplicationRecord
  belongs_to :student
  belongs_to :parent, class_name: 'User'  # Assuming parent is a User
  belongs_to :created_by, class_name: 'User', optional: true
  has_many :invoice_items, dependent: :destroy
  has_many :fees, through: :invoice_items

  enum status: { pending: 0, paid: 1, overdue: 2, cancelled: 3, partially_paid: 4 }

  validates :month, presence: true, numericality: { greater_than: 0, less_than: 13 }
  validates :year, presence: true, numericality: { greater_than: 2000, less_than: 2100 }
  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :due_date, presence: true
  validates :student_id, presence: true
  validates :parent_id, presence: true

  scope :for_month, ->(month, year) { where(month: month, year: year) }
  scope :pending, -> { where(status: :pending) }
  scope :overdue, -> { where(status: :pending).where('due_date < ?', Date.current) }

  def month_year
    Date.new(year, month, 1).strftime("%B %Y")
  end

  def status_label
    case status
    when 'pending'
      'Pending'
    when 'paid'
      'Paid'
    when 'overdue'
      'Overdue'
    when 'cancelled'
      'Cancelled'
    when 'partially_paid'
      'Partially Paid'
    else
      'Unknown'
    end
  end

  def overdue?
    status_pending? && due_date < Date.current
  end

  def paid?
    status_paid?
  end

  def pending?
    status_pending?
  end

  def amount_paid
    # Calculate amount paid based on associated payments
    # This would sum all payments linked to fees in this invoice
    payments_sum = 0
    invoice_items.includes(:fee).each do |item|
      payments_sum += item.fee.payments.sum(:amount) if item.fee
    end
    payments_sum
  end

  def balance_remaining
    total_amount - amount_paid
  end

  def days_until_due
    (due_date - Date.current).to_i
  end

  def due_soon?
    days_until_due <= 7 && days_until_due >= 0
  end

  def invoice_number
    "INV-#{id.to_s.rjust(6, '0')}"
  end

  def issue_date
    created_at.to_date
  end
end