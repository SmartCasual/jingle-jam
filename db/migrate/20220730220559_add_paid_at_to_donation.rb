class AddPaidAtToDonation < ActiveRecord::Migration[7.0]
  def change
    add_column :donations, :paid_at, :datetime
    add_index :donations, :paid_at
  end
end