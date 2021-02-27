class RemoveBundleIdFromDonation < ActiveRecord::Migration[6.1]
  def change
    remove_column :donations, :bundle_id, :belongs_to
  end
end
