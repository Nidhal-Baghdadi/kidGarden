class CreateConversationParticipants < ActiveRecord::Migration[8.0]
  def change
    create_table :conversation_participants do |t|
      t.references :conversation, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :joined_at
      t.datetime :left_at
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :conversation_participants, [:conversation_id, :user_id], unique: true
    add_index :conversation_participants, :active
    add_index :conversation_participants, :joined_at
  end
end
