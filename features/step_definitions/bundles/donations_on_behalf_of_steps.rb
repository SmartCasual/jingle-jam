When("someone else makes a {amount} donation on their behalf") do |amount|
  original_donator = Donator.last
  log_out

  original_donator.update(email_address: "test-original@example.com")
  original_donator.confirm

  make_donation(amount,
    navigate: true,
    submit: true,
    on_behalf_of: original_donator,
  )
  log_out

  log_in_as(original_donator)
  go_to_donations
end

Then("a {amount} donation should be recorded under the name {string}") do |amount, name|
  go_to_donations
  expect(page).to have_text("#{amount.format} Paid #{name}")
end

Then("the {amount} donation should appear as a gifted donation on the other person's donation list") do |amount|
  log_out
  log_in_as(Donator.last)
  go_to_donations
  expect(page).to have_text("Your gifted donations")
  expect(page).to have_text("#{amount.format} Paid Anonymous")
end
