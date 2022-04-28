When("a donator makes a donation via paypal") do
  make_donation(Money.new(10_00, "GBP"),
    paypal: true,
    navigate: true,
  )
end

Then("the donation should be recorded") do
  expect(page).to have_content("£10")
end

Then("the donation should have a paypal ID associated with it") do
  expect(Donation.last.paypal_order_id).to be_present
end

When("a donator makes a donation via stripe") do
  make_donation(Money.new(10_00, "GBP"),
    paypal: false,
    navigate: true,
  )
end

Then("the donation should have a stripe ID associated with it") do
  expect(Donation.last.stripe_payment_intent_id).to be_present
end
