class CreateStudents < ActiveRecord::Migration[8.0]
  def change
    create_table :students do |t|
      t.string :first_name
      t.string :last_name
      t.date :date_of_birth
      t.date :enrollment_date
      t.integer :status
      t.integer :gender
        t.string :emergency_contact_name
        t.string :emergency_contact_phone
        t.text :medical_information
        t.integer :parent_id
        t.integer :classroom_id

        t.timestamps
      end

      add_index :students, :parent_id
      add_index :students, :classroom_id
      add_index :students, :status
      add_foreign_key :students, :users, column: :parent_id
      add_foreign_key :students, :classrooms, column: :classroom_id
  end
end
