class CreateClassrooms < ActiveRecord::Migration[8.0]
  def change
    create_table :classrooms do |t|
      t.string :name
      t.integer :capacity
      t.text :description
      t.integer :teacher_id
      t.text :schedule

      t.timestamps
    end

    add_index :classrooms, :teacher_id
    add_foreign_key :classrooms, :users, column: :teacher_id
  end
end
