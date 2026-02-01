class CreateParentStudentRelationships < ActiveRecord::Migration[8.0]
  def change
    create_table :parent_student_relationships do |t|
      t.integer :parent_id
      t.integer :student_id
      t.integer :relationship_type
      t.integer :contact_priority
      t.boolean :active

      t.timestamps
    end

    add_index :parent_student_relationships, :parent_id
    add_index :parent_student_relationships, :student_id
    add_index :parent_student_relationships, [:parent_id, :student_id], unique: true
    add_foreign_key :parent_student_relationships, :users, column: :parent_id
    add_foreign_key :parent_student_relationships, :students
  end
end
