class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.string :title
      t.text :description
      t.datetime :start_time
      t.datetime :end_time
      t.string :location
      t.integer :organizer_id

      t.timestamps
    end

    add_index :events, :organizer_id
    add_index :events, :start_time
    add_foreign_key :events, :users, column: :organizer_id
  end
end
