Given("a donator with a confirmed email address") do
  @email_address = "test-#{rand(1_000_000)}@example.com"

  @donator = create(:donator, :confirmed,
    email_address: @email_address,
  )
end

Given("a donator with an unconfirmed email address") do
  @email_address = "test-#{rand(1_000_000)}@example.com"

  @donator = create(:donator,
    email_address: @email_address,
  )
end

When("they request a log in URL") do
  request_login_email(@email_address)
end

When("someone requests a log in URL for a non-existent account") do
  request_login_email("non-existent@example.net")
end

Then("they should receive a log in URL") do
  expect(find_email_with_link(%r{/log-in-via-token/})).to be_present
end

Then("they should not receive a log in URL") do
  expect(find_email_with_link(%r{/log-in-via-token/})).not_to be_present
end
