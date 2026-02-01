class CreatePhotos < ActiveRecord::Migration[8.0]
  def change
    create_table :photos do |t|
      t.references :student, null: false, foreign_key: true
      t.references :uploaded_by, null: false, foreign_key: { to_table: :users }
      t.references :classroom, null: true, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.string :category # e.g., 'activity', 'event', 'milestone', 'daily_life'
      t.boolean :visible_to_parents, default: true
      t.boolean :approved, default: false
      t.datetime :taken_at

      t.timestamps
    end

    add_index :photos, :title
    add_index :photos, :category
    add_index :photos, :visible_to_parents
    add_index :photos, :approved
    add_index :photos, :taken_at
    add_index :photos, [:student_id, :created_at]
    add_index :photos, [:uploaded_by_id, :created_at]
    add_index :photos, [:classroom_id, :created_at]
  end
end
