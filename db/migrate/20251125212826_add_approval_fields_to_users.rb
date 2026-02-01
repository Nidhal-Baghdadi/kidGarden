class AddApprovalFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :approved, :boolean, default: false
    add_column :users, :approved_at, :datetime
    add_column :users, :verification_code, :string
    add_column :users, :role_request, :integer # to track requested role during registration
  end
end
