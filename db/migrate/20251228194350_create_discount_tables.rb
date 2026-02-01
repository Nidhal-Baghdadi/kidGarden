class CreateDiscountTables < ActiveRecord::Migration[8.0]
  def change
    create_table :fee_categories do |t|
      t.string :name, null: false
      t.text :description
      t.boolean :is_discount, default: false
      t.decimal :discount_percentage, precision: 5, scale: 2
      t.boolean :active, default: true
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end

    create_table :discounts do |t|
      t.string :name, null: false
      t.text :description
      t.integer :fee_category_id # If discount applies to specific category
      t.string :discount_type, null: false # percentage, fixed_amount, sibling_discount
      t.decimal :value, precision: 10, scale: 2, null: false
      t.string :applicable_to, null: false # tuition, all_fees, specific_fees
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.boolean :active, default: true
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end

    create_table :fee_discounts do |t|
      t.references :fee, null: false, foreign_key: true
      t.references :discount, null: false, foreign_key: true
      t.decimal :applied_amount, precision: 10, scale: 2, default: 0.0
      t.text :notes

      t.timestamps
    end

    add_index :discounts, :fee_category_id
    add_index :discounts, :discount_type
    add_index :discounts, :applicable_to
    add_index :fee_discounts, [:fee_id, :discount_id], unique: true
  end
end
