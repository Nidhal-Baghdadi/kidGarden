class Discount < ApplicationRecord
  belongs_to :fee_category
  belongs_to :student, optional: true # If nil, applies to all students
  belongs_to :family, optional: true # If nil, applies to all families
  belongs_to :classroom, optional: true # If nil, applies to all classrooms

  enum :discount_type, { percentage: 0, fixed_amount: 1, sibling_discount: 2 }
  enum :applicable_to, { tuition: 0, all_fees: 1, specific_fees: 2 }

  validates :name, presence: true
  validates :discount_type, presence: true
  validates :applicable_to, presence: true
  validates :value, presence: true, numericality: { greater_than: 0 }
  validates :start_date, presence: true
  validates :end_date, presence: true

  validate :end_date_after_start_date

  def active?
    start_date <= Date.current && end_date >= Date.current
  end

  private

  def end_date_after_start_date
    return unless start_date.present? && end_date.present?

    if end_date <= start_date
      errors.add(:end_date, 'must be after start date')
    end
  end
end