class AddDonatorNameToDonation < ActiveRecord::Migration[7.0]
  def change
    add_column :donations, :donator_name, :string
  end
end
