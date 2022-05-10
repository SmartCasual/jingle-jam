Given("a bundle with the following tiers:") do |table|
  tiers_and_games = table.symbolic_hashes.each.with_object(Hash.new { |h, k| h[k] = [] }) do |row, hash|
    hash[Monetize.parse(row.fetch(:tier))] << row.fetch(:game)
  end

  @current_bundle = create(:bundle, :live,
    bundle_tiers: tiers_and_games.map { |tier, games|
      build(:bundle_tier,
        games: games.map { |g| create(:game, :with_keys, name: g) },
        price: tier,
      )
    },
  )
end

Then("a key should be assigned for {string}") do |game_name|
  game = Game.find_by!(name: game_name)
  expect(Key.assigned.where(game:)).to be_any
end

Then("a key should not be assigned for {string}") do |game_name|
  game = Game.find_by!(name: game_name)
  expect(Key.assigned.where(game:)).to be_none
end
