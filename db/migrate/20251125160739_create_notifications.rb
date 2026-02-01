class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.string :title
      t.text :message
      t.string :recipient_type
      t.integer :recipient_id
      t.integer :sender_id
      t.datetime :sent_at
      t.datetime :read_at
      t.integer :notification_type

      t.timestamps
    end

    add_index :notifications, :recipient_id
    add_index :notifications, :sender_id
    add_index :notifications, :notification_type
    add_index :notifications, :sent_at
    add_foreign_key :notifications, :users, column: :sender_id
  end
end
