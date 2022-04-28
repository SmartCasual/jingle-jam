Given("a donator is logged in") do
  @current_donator = log_in_as(:donator)
end

When("the donator provides an email address but no password") do
  update_login_options(email_address: "test@example.com")
end

When("the donator provides an email address and password") do
  update_login_options(
    email_address: "test@example.com",
    password: "password123",
  )
end

Then("they should receive a confirmation email") do
  expect(email_with_subject("Confirmation instructions")).to be_present
end

Then("they should (still )not be able to log in via the email & password login page") do
  log_out
  log_in_donator_with(
    email_address: @current_donator.reload.email_address,
    password: "",
    expect_failure: true,
  )
end

Then("they should be able to log in via the email & password login page") do
  log_out(navigate: false)
  log_in_donator_with(
    email_address: @current_donator.reload.email_address,
    password: "password123",
    expect_failure: false,
  )
end
