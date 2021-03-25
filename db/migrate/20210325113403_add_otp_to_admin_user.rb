class AddOtpToAdminUser < ActiveRecord::Migration[6.1]
  def change
    add_column :admin_users, :otp_secret, :string
    add_column :admin_users, :last_otp_at, :datetime
  end
end
