class AddFieldsToFee < ActiveRecord::Migration[8.0]
  def change
    add_column :fees, :total_amount, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :fees, :discount_amount, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :fees, :fee_category_id, :integer

    add_index :fees, :fee_category_id
  end
end
