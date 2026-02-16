class AddOtpFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :otp_secret, :string
    add_column :users, :otp_attempts_count, :integer, default: 0
    add_column :users, :otp_last_attempt_at, :datetime
    add_column :users, :otp_expires_at, :datetime
    add_column :users, :otp_sent_at, :datetime
  end
end