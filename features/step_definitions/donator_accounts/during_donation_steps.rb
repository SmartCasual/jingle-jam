When("a donator makes a donation without giving a name or an email address") do
  make_donation(Money.new(10_00, "GBP"),
    email_address: false,
    navigate: true,
    expect_failure: true,
  )
end

When("a donator makes a donation giving a name but no email address") do
  make_donation(Money.new(10_00, "GBP"),
    name: "Test Donator",
    email_address: false,
    navigate: true,
    expect_failure: true,
  )
end

When("a donator makes a donation giving an email address") do
  @expected_email_address = "test@example.com"
  make_donation(Money.new(10_00, "GBP"),
    navigate: true,
    email_address: @expected_email_address,
  )
end

When("a donator makes a donation giving an email address from Stripe") do
  @expected_email_address = "test@example.com"
  make_donation(Money.new(10_00, "GBP"),
    navigate: true,
    email_address: @expected_email_address,
    stripe_options: {
      email_address: "some-other@example.com",
    },
  )
end

When("a donator makes a donation giving an email address from Paypal") do
  @expected_email_address = "test@example.com"
  amount = Money.new(10_00, "GBP")

  order_id = stub_paypal_order_creation(amount:)
  stub_paypal_payment_capture(
    email_address: ENV.fetch("PAYPAL_TEST_DONATOR_EMAIL_ADDRESS", nil),
    order_id:,
  )

  make_donation(amount, navigate: true, paypal: true, email_address: @expected_email_address)
end

Then("an anonymous account should have been made for the donator") do
  expect(Donator.count).to eq(1)
  expect(Donation.count).to eq(1)
  expect(Donation.last.donator).to be_anonymous

  @current_donator = Donation.last.donator
end

Then("an account should have been made for the donator with their name") do
  expect(Donator.count).to eq(1)
  expect(Donation.count).to eq(1)

  @current_donator = Donation.last.donator
  expect(@current_donator.name).to eq("Test Donator")
end

Then("an account should have been made for the donator with their email address") do
  expect(Donator.count).to eq(1)
  expect(Donation.count).to eq(1)

  @current_donator = Donation.last.donator
  expect(@current_donator.email_address.presence || @current_donator.unconfirmed_email_address)
    .to eq(@expected_email_address)
end

Then("the donator should have been logged in") do
  expect_logged_in(@current_donator)
end

Then("the donator should see a token log-in link on the page") do
  expect(page).to have_content(log_in_via_token_account_path(@current_donator, token: @current_donator.token))
end

Then("the donator should have been sent a token log-in link via email") do
  email = email_with_subject("Account created")
  expect(email).to be_present

  @link_from_email = extract_links_from_email(email).find { |link|
    link.include?("token")
  }

  expect(@link_from_email).to be_present
end

Then("the donator's email address should not be confirmed") do
  expect(@current_donator).not_to be_confirmed
end

When("the donator puts that link aside") do
  @token_link = page.first(".token-url")[:href]
end

When("the donator logs out") do
  click_on "Log out"
end

Then("the donator should be able to log back in with their link") do
  visit @token_link
  click_on "Log in via token"
  expect_logged_in(@current_donator)
end

Then("the donator should be able to log back in with the link in the email") do
  visit @link_from_email
  click_on "Log in via token"
  expect_logged_in(@current_donator)
end

Then("the donator's email address should now be confirmed") do
  expect(@current_donator.reload).to be_confirmed
end

Then("they should be told that an email address is required") do
  expect(page).to have_content("You must provide an email address")
end
