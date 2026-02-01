class CreateInvoices < ActiveRecord::Migration[8.0]
  def change
    create_table :invoices do |t|
      t.references :student, null: false, foreign_key: true
      t.references :parent, null: false, foreign_key: { to_table: :users }  # Reference User table instead
      t.references :created_by, null: true, foreign_key: { to_table: :users }
      t.integer :month, null: false
      t.integer :year, null: false
      t.decimal :total_amount, precision: 10, scale: 2, null: false
      t.date :due_date, null: false
      t.string :status, default: 'pending'
      t.text :notes
      t.string :invoice_number
      t.date :issue_date, default: -> { 'CURRENT_DATE' }
      t.json :metadata

      t.timestamps
    end

    create_table :invoice_items do |t|
      t.references :invoice, null: false, foreign_key: true
      t.references :fee, null: true, foreign_key: true  # null allowed in case fee is deleted
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.text :description
      t.json :metadata

      t.timestamps
    end

    add_index :invoices, :status
    add_index :invoices, :due_date
    add_index :invoices, :month
    add_index :invoices, :year
    add_index :invoices, [:month, :year]
    add_index :invoices, :invoice_number
  end
end
