class FeeDiscount < ApplicationRecord
  belongs_to :fee
  belongs_to :discount

  validates :fee_id, uniqueness: { scope: :discount_id }
end