Given("a bundle with the following games:") do |table|
  @current_bundle = create(:bundle, :empty, :live)
  table.symbolic_hashes.each do |hash|
    @current_bundle.highest_tier.games << create(:game, name: hash[:game], description: hash[:description])
  end
end

When("a donator makes a {amount} donation with the message {string}") do |amount, message|
  make_donation(amount, message:, navigate: true)
end

When("a/the donator makes a/another {amount} donation") do |amount|
  make_donation(amount, navigate: true)
end

Then("a {amount} donation should be recorded with the message {string}") do |amount, message|
  go_to_donations
  expect(page).to have_text("#{amount.format} Paid #{message}")
end

Then("a {amount} donation should be recorded") do |amount|
  go_to_donations
  expect(page).to have_css(".donation-list td", text: amount.format)
end

Then("no keys should have been assigned for that bundle") do
  expect(@current_bundle.donator_bundles.flat_map(&:donator_bundle_tiers).flat_map { |t| t.keys.assigned }).to be_empty
end

Then("one key per game in the bundle should have been assigned") do
  go_to_game_keys
  @current_bundle.bundle_tiers.flat_map(&:games).each do |game|
    expect(page).to have_css(".key .game", text: game.name)
    expect(page).to have_css(".key .code", text: RegexHelpers::UUID_PATTERN)
  end
end
