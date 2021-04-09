class AddPermissionsToAdminUser < ActiveRecord::Migration[6.1]
  def change
    add_column :admin_users, :data_entry, :boolean, null: false, default: false, index: true
    add_column :admin_users, :support, :boolean, null: false, default: false, index: true
    add_column :admin_users, :manages_users, :boolean, null: false, default: false, index: true
    add_column :admin_users, :full_access, :boolean, null: false, default: false, index: true
  end
end
