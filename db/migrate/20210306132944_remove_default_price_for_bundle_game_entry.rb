class RemoveDefaultPriceForBundleGameEntry < ActiveRecord::Migration[6.1]
  def change
    change_column_default(:bundle_definition_game_entries, :price_currency, from: "GBP", to: nil)
    change_column_default(:bundle_definition_game_entries, :price_decimals, from: 0, to: nil)
  end
end
