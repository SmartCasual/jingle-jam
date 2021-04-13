class AddNameToAdminUser < ActiveRecord::Migration[6.1]
  def change
    add_column :admin_users, :name, :string, index: true
    AdminUser.reset_column_information
    AdminUser.update_all("name = email")
    change_column_null :admin_users, :name, :false
  end
end
