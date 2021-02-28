Given("a simple bundle priced at {amount}") do |amount|
  @current_bundle_definition = FactoryBot.create(:bundle_definition, price: amount)
  expect(@current_bundle_definition.keys.unassigned).to exist
  expect(@current_bundle_definition.keys.assigned).not_to exist
end

When("an anonymous donator makes a {amount} donation with the message {string}") do |amount, message|
  make_donation(amount, message: message)
end

When("an/the anonymous donator makes a/another {amount} donation") do |amount|
  make_donation(amount)
end

Then("a {amount} donation should be recorded with the message {string}") do |amount, message|
  expect(page).to have_text("#{amount.format} Paid #{message}")
end

Then("a {amount} donation should be recorded") do |amount|
  expect(page).to have_css(".donation-list td", text: "#{amount.format}")
end

Then("no keys should have been assigned for that bundle") do
  expect(@current_bundle_definition.keys.unassigned).to exist
  expect(@current_bundle_definition.keys.assigned).not_to exist
end

Then("one key per game in the bundle should have been assigned") do
  @current_bundle_definition.games.each do |game|
    expect(Key.assigned.where(game: game).count).to eq(1)
  end
end
