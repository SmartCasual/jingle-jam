class RenameEmailOnAdminUser < ActiveRecord::Migration[7.0]
  def change
    rename_column :admin_users, :email, :email_address
  end
end
