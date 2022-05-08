module Admin::BundleTestHelpers
  def add_tiers_and_games_to_bundle(tiers_and_games, bundle:, navigate: false)
    go_to_admin_bundle(bundle, edit: true) if navigate

    tiers_and_games.sort.reverse.each.with_index do |(tier_price, games), tier_index|
      click_on "Add a bundle tier" unless tier_index.zero?

      within ".bundle_tiers > fieldset:last-of-type" do
        select tier_price.currency.iso_code, from: "Currency"
        fill_in "Price", with: tier_price.format(symbol: false), fill_options: { clear: :backspace }

        games.each.with_index do |game, game_index|
          click_on "Add a game to this tier" unless tier_index.zero? && game_index.zero?
          within ".bundle_tier_games > fieldset:last-of-type" do
            select game, from: "Game"
          end
        end
      end
    end
  end
end

World(Admin::BundleTestHelpers)
