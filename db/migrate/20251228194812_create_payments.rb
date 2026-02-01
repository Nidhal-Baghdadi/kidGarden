class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :fee, null: false, foreign_key: true
      t.references :student, null: true, foreign_key: true
      t.references :created_by, null: true, foreign_key: { to_table: :users }
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :payment_method, null: false
      t.string :status, default: 'pending'
      t.text :notes
      t.string :reference_number
      t.date :payment_date, null: false
      t.string :transaction_id
      t.json :payment_metadata

      t.timestamps
    end

    add_index :payments, :payment_method
    add_index :payments, :status
    add_index :payments, :payment_date
    add_index :payments, :reference_number
    add_index :payments, :transaction_id
  end
end
