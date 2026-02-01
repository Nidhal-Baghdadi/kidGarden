class CreateMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :messages do |t|
      t.references :conversation, null: false, foreign_key: true
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.references :recipient, null: false, foreign_key: { to_table: :users }
      t.text :content
      t.string :message_type, default: 'text' # text, image, document, multimedia
      t.boolean :read_status, default: false
      t.datetime :delivered_at
      t.datetime :read_at

      t.timestamps
    end

    add_index :messages, :message_type
    add_index :messages, [:conversation_id, :created_at]
    add_index :messages, :read_status
    add_index :messages, :created_at
  end
end
