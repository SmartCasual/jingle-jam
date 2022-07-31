When("someone else makes a {amount} donation on their behalf") do |amount|
  original_donator = Donator.last
  log_out

  original_donator.update(email_address: "test-giftee@example.com")
  original_donator.confirm

  ActionMailer::Base.deliveries.clear

  make_donation(amount,
    email_address: "test-gifter@example.com",
    navigate: true,
    submit: true,
    on_behalf_of: original_donator,
  )

  @gifter = Donator.last
  @giftee = original_donator

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
  log_in_as(@gifter)
  go_to_donations
  expect(page).to have_text("Your gifted donations")
  expect(page).to have_text("#{amount.format} Paid Anonymous")
end

Then("both people should have received an email about the donation") do
  gifter_email = email_with_subject("Gift sent", recipient: @gifter.email_address)
  expect(gifter_email.text_part.to_s).to include("Thanks for your donation gift")

  giftee_email = email_with_subject("Donation received", recipient: @giftee.email_address)
  expect(giftee_email.text_part.to_s).to include("A donation has been made on your behalf")
end
