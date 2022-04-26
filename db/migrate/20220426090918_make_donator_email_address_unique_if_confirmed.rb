class MakeDonatorEmailAddressUniqueIfConfirmed < ActiveRecord::Migration[7.0]
  def change
    remove_index :donators, :email_address, unique: true
    add_index :donators, :email_address, unique: true, where: "confirmed_at IS NOT NULL"
  end
end
