class CreateResources < ActiveRecord::Migration[8.0]
  def change
    create_table :resources do |t|
      t.string :title
      t.text :description
      t.string :category
      t.integer :classroom_id
      t.integer :user_id
      t.string :subject

      t.timestamps
    end
  end
end
