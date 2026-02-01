class CreateFees < ActiveRecord::Migration[8.0]
  def change
    create_table :fees do |t|
      t.integer :student_id
      t.decimal :amount, precision: 10, scale: 2
      t.date :due_date
      t.integer :status
      t.text :description
      t.string :receipt_number

      t.timestamps
    end

    add_index :fees, :student_id
    add_index :fees, :status
    add_index :fees, :due_date
    add_foreign_key :fees, :students
  end
end
