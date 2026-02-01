class FeeCategory < ApplicationRecord
  has_many :fees, dependent: :nullify

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :description, presence: true
  validates :is_discount, inclusion: { in: [true, false] }
  validates :discount_percentage, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, if: :is_discount?

  def discount?
    is_discount
  end
end