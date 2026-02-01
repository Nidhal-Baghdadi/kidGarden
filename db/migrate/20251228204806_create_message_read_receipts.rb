class CreateMessageReadReceipts < ActiveRecord::Migration[8.0]
  def change
    create_table :message_read_receipts do |t|
      t.references :message, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :read_at, null: false

      t.timestamps
    end

    add_index :message_read_receipts, [:message_id, :user_id], unique: true
    add_index :message_read_receipts, :read_at
  end
end
