class CreateCurriculums < ActiveRecord::Migration[8.0]
  def change
    create_table :curriculums do |t|
      t.string :title
      t.text :description
      t.datetime :start_time
      t.datetime :end_time
      t.integer :classroom_id
      t.string :subject

      t.timestamps
    end
  end
end
