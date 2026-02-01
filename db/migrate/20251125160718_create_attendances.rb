class CreateAttendances < ActiveRecord::Migration[8.0]
  def change
    create_table :attendances do |t|
      t.integer :student_id
      t.date :date
      t.integer :status
      t.text :notes
      t.integer :staff_id

      t.timestamps
    end

    add_index :attendances, :student_id
    add_index :attendances, :date
    add_index :attendances, [:student_id, :date], unique: true
    add_index :attendances, :staff_id
    add_foreign_key :attendances, :students
    add_foreign_key :attendances, :users, column: :staff_id
  end
end
