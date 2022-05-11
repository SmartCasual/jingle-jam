class AddDatesToBundleTier < ActiveRecord::Migration[7.0]
  def change
    add_column :bundle_tiers, :starts_at, :datetime
    add_column :bundle_tiers, :ends_at, :datetime
  end
end
