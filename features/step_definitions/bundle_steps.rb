Given("a bundle with the following games:") do |table|
  @current_bundle = create(:bundle, :empty, :live)
  table.symbolic_hashes.each do |hash|
    @current_bundle.highest_tier.games << create(:game, name: hash[:game], description: hash[:description])
  end
end

When("a donator makes a {amount} donation with the message {string}") do |amount, message|
  make_donation(amount, message:, navigate: true)
end

When("a donator makes a {amount} donation") do |amount|
  make_donation(amount, navigate: true)
end

When("the donator makes another {amount} donation") do |amount|
  make_donation(amount, navigate: true, email_address: false)
end

Then("a {amount} donation should be recorded with the message {string}") do |amount, message|
  go_to_donations
  expect(page).to have_text("#{amount.format} Paid #{message}")
end

Then("a {amount} donation should be recorded") do |amount|
  go_to_donations
  expect(page).to have_css(".donation-list td", text: amount.format)
end

Then("no keys should have been assigned for that bundle") do
  expect(@current_bundle.donator_bundles.flat_map(&:donator_bundle_tiers).flat_map { |t| t.keys.assigned }).to be_empty
end

Then("one key per game in the bundle should have been assigned") do
  go_to_game_keys
  @current_bundle.bundle_tiers.flat_map(&:games).each do |game|
    expect(page).to have_css(".key .game", text: game.name)
    expect(page).to have_css(".key .code", text: RegexHelpers::UUID_PATTERN)
  end
end

When("a donator tries to make a very long donation using the web form") do
  make_donation(
    message: "a" * 1000,
    navigate: true,
    submit: false,
  )
end

Then("the donation message should be cut off in the form") do
  expect(find_field("Message").value).to eq("a" * Donation::MAX_MESSAGE_LENGTH)
end

Then("the donation should be recorded with the truncated message") do
  make_donation(
    message: "a" * 1000,
    navigate: true,
    submit: true,
  )

  expect(Donation.last.message).to eq("a" * Donation::MAX_MESSAGE_LENGTH)
end

Then("the donation should still be recorded with the truncated message") do
  make_donation(
    message: "a" * 1000,
    email_address: false,
    navigate: true,
    submit: true,
  )

  expect(Donation.last.message).to eq("a" * Donation::MAX_MESSAGE_LENGTH)
end

When("a donator bypasses the donation message truncation in the form") do
  find_field("Message").execute_script("this['maxlength'] = '#{'a' * (Donation::MAX_MESSAGE_LENGTH + 1)}'")
end
