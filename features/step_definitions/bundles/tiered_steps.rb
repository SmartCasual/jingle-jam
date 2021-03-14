Given("a tiered bundle priced at {amount} with the following tiers:") do |amount, table|
  @current_bundle_definition = FactoryBot.create(:bundle_definition, :empty, price: amount)
  @current_bundle_definition.bundle_definition_game_entries = table.symbolic_hashes.map { |hash|
    FactoryBot.create(:bundle_definition_game_entry,
      game: FactoryBot.create(:game, :with_keys, name: hash[:game]),
      bundle_definition: @current_bundle_definition,
      price: (Monetize.parse(hash[:tier_price]) unless hash[:tier_price] == "bundle price"),
    )
  }
end

Then("a key should be assigned for {string}") do |game_name|
  game = Game.find_by!(name: game_name)
  expect(Key.assigned.where(game: game)).to exist
end

Then("a key should not be assigned for {string}") do |game_name|
  game = Game.find_by!(name: game_name)
  expect(Key.assigned.where(game: game)).not_to exist
end
