class InvoiceItem < ApplicationRecord
  belongs_to :invoice
  belongs_to :fee, optional: true  # Optional in case the original fee is deleted

  validates :amount, presence: true, numericality: { greater_than: 0 }

  def description
    if fee
      fee.description || "Fee ##{fee.id}"
    else
      "Deleted Fee Item"
    end
  end
end