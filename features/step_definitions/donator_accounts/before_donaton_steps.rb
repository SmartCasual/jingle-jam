When("someone signs up with the email address {string}") do |email_address|
  create_donator_account(email_address:)
  @current_donator = Donator.find_by!(email_address:)
end

When("someone signs up via Twitch with the email address {string}") do |email_address|
  stub_twitch_auth(info: { name: "Twitch User", email: email_address }) do
    create_donator_account(provider: :twitch)
  end
  @current_donator = Donator.find_by!(email_address:)
end

When("they confirm their email address") do
  confirm_email_address
end

When("they immediately make a donation") do
  @amount = Money.new(10_00, "GBP")

  expect {
    make_donation(@amount, navigate: true, email_address: false)
  }.to(change { @current_donator.reload.donations.count }.by(1))
end

Then("the donation should be associated with their account") do
  expect(@current_donator.donations.last.amount).to eq(@amount)
end

When("they sign out and make a donation giving the email address {string}") do |email_address|
  log_out
  @amount = Money.new(20_00, "GBP")
  make_donation(@amount, navigate: true, email_address:)
end
