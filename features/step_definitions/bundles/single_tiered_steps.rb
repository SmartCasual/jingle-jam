When("a donator makes a {amount} donation with the name {string}") do |amount, name|
  make_donation(amount, name:, navigate: true)
end

Then("a {amount} donation should be recorded with the name {string}") do |amount, name|
  go_to_donations
  expect(page).to have_text("#{amount.format} Paid #{name}")
end
