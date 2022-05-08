class CreateTier < ActiveRecord::Migration[7.0]
  def change
    rename_table :bundles, :donator_bundles
    rename_table :bundle_definitions, :bundles

    change_column_null :bundles, :fundraiser_id, false
    add_index :bundles, [:name, :fundraiser_id], unique: true

    rename_column :donator_bundles, :bundle_definition_id, :bundle_id

    remove_column :bundles, :price_currency, :string, default: "GBP", null: false
    remove_column :bundles, :price_decimals, :integer, default: 0, null: false

    create_table :bundle_tiers do |t|
      t.monetize :price
      t.string :name
      t.references :bundle, null: false, foreign_key: true, index: true

      t.timestamps
    end

    rename_table :bundle_definition_game_entries, :bundle_tier_games
    rename_column :bundle_tier_games, :bundle_definition_id, :bundle_tier_id
    remove_column :bundle_tier_games, :price_currency, :string, default: "GBP", null: false
    remove_column :bundle_tier_games, :price_decimals, :integer, default: 0, null: false

    create_table :donator_bundle_tiers do |t|
      t.references :donator_bundle, null: false, foreign_key: true, index: true
      t.references :bundle_tier, null: false, foreign_key: true, index: true

      t.boolean :unlocked, default: false, null: false

      t.timestamps
    end

    rename_column :keys, :bundle_id, :donator_bundle_tier_id

    change_column_null :donator_bundles, :donator_id, false

    add_column :fundraisers, :main_currency, :string, default: "GBP", null: false
  end
end
