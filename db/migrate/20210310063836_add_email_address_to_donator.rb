class AddEmailAddressToDonator < ActiveRecord::Migration[6.1]
  def change
    add_column :donators, :email_address, :string
  end
end
