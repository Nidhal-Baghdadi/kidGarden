class CreateConversations < ActiveRecord::Migration[8.0]
  def change
    create_table :conversations do |t|
      t.string :subject, null: false
      t.text :description
      t.integer :creator_id
      t.string :conversation_type, default: 'private' # private, group, class
      t.boolean :archived, default: false
      t.datetime :last_activity_at

      t.timestamps
    end

    add_index :conversations, :creator_id
    add_index :conversations, :conversation_type
    add_index :conversations, :last_activity_at
    add_index :conversations, :archived
  end
end
