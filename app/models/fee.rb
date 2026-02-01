class Fee < ApplicationRecord
  belongs_to :student
  belongs_to :fee_category, optional: true
  has_many :fee_discounts, dependent: :destroy
  has_many :discounts, through: :fee_discounts

  enum :status, { pending: 0, paid: 1, overdue: 2, waived: 3 }

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :due_date, presence: true
  validates :student_id, presence: true

  before_save :calculate_total_amount

  def calculate_total_amount
    # Calculate discounts applied to this fee
    discount_amount = calculate_discounts
    self.discount_amount = discount_amount
    self.total_amount = amount - discount_amount
    self.total_amount = 0 if total_amount < 0
  end

  def calculate_discounts
    discount_total = 0

    # Apply direct discounts to this fee
    fee_discounts.includes(:discount).each do |fee_discount|
      discount = fee_discount.discount
      next unless discount.active?

      if discount.discount_type_percentage?
        discount_amount = amount * (discount.value / 100.0)
        discount_total += discount_amount
      elsif discount.discount_type_fixed_amount?
        discount_amount = [discount.value, amount].min
        discount_total += discount_amount
      end
    end

    # Apply family-wide discounts for siblings
    discount_total += apply_sibling_discounts
    discount_total
  end

  def apply_sibling_discounts
    discount_total = 0

    # Find all students in the same family (same parent)
    family_students = Student.joins(:parent_student_relationships)
                            .where(parent_student_relationships: { parent_id: student.parent_id })
                            .distinct

    if family_students.count > 1
      # Look for sibling discounts
      sibling_discounts = Discount.where(
        discount_type: 'sibling_discount',
        applicable_to: ['tuition', 'all_fees', 'specific_fees'],
        start_date: ..Date.current,
        end_date: Date.current..
      ).where(active: true)

      sibling_discounts.each do |discount|
        if discount.applicable_to == 'specific_fees'
          next unless discount.fee_category_id == fee_category_id
        end

        # Apply additional discount based on number of siblings
        if discount.discount_type_fixed_amount?
          discount_total += [discount.value, amount].min
        elsif discount.discount_type_percentage?
          discount_total += amount * (discount.value / 100.0)
        end
      end
    end

    discount_total
  end

  def status_label
    case status
    when 'pending'
      'Pending'
    when 'paid'
      'Paid'
    when 'overdue'
      'Overdue'
    when 'waived'
      'Waived'
    else
      'Unknown'
    end
  end

  def overdue?
    status_overdue? || (status_pending? && due_date < Date.current)
  end
end
