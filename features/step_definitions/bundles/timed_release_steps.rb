Given("a bundle with the following time-released tiers:") do |table|
  @current_bundle = create(:bundle, :live, :empty)
  @fundraiser = @current_bundle.fundraiser

  table.hashes.each do |row|
    price = Monetize.parse(row.fetch("Tier"))
    tier = @current_bundle.bundle_tiers.find_or_create_by!(
      price_currency: price.currency,
      price_decimals: price.cents,
      starts_at: row.fetch("Starts at"),
      ends_at: row.fetch("Ends at"),
    )

    tier.games << create(:game, :with_keys, name: row.fetch("Game"))
  end
end

Then("the dates for the tiers should be shown on the fundraiser page:") do |table|
  go_to_fundraiser(@fundraiser)

  table.hashes.each do |row|
    tier_block = page.find("h4", text: row.fetch("Tier")).ancestor(".tier")

    within tier_block do
      availability_tier_block = page.find("h5", text: row.fetch("Availability")).ancestor(".availability-tier")

      within availability_tier_block do
        row.fetch("Games").split(", ").each do |game|
          expect(page).to have_css(".game", text: game)
        end
      end
    end
  end
end
