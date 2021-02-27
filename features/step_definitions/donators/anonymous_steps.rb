Given("the bundle price is set to {amount}") do |amount|
  FactoryBot.create(:bundle_definition, price: amount)
end

When("an anonymous donator makes a {amount} donation with the message {string}") do |amount, message|
  go_to_homepage
  click_on "Donate here!"

  select amount.currency.iso_code, from: "Currency"
  fill_in "Amount", with: amount.to_s
  fill_in "Message", with: message

  click_on "Donate"
end

Then("a {amount} donation should be recorded with the message {string}") do |amount, message|
  expect(page).to have_text("#{amount.format} Paid #{message}")
end

Then("no bundles should have been assigned") do
  expect(Bundle.assigned).not_to exist
end
