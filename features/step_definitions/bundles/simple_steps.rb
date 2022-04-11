Given("a simple bundle priced at {amount}") do |amount|
  @current_bundle_definition = FactoryBot.create(:bundle_definition, :live, price: amount)
  expect(@current_bundle_definition.keys.unassigned).to exist
  expect(@current_bundle_definition.keys.assigned).not_to exist
end

When("a donator makes a {amount} donation with the name {string}") do |amount, name|
  make_donation(amount, name:, navigate: true)
end

Then("a {amount} donation should be recorded with the name {string}") do |amount, name|
  expect(page).to have_text("#{amount.format} Paid #{name}")
end
