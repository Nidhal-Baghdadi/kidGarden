class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :encrypted_password
      t.integer :role
      t.integer :status
      t.string :phone
      t.date :date_of_birth
      t.text :address
      t.string :avatar

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :role
    add_index :users, :status
  end
end
