Given("a fundraiser in pro bono mode") do
  @fundraiser = create(:fundraiser, :active, overpayment_mode: Fundraiser::PRO_BONO)
  @bundle = create(:bundle, :live, fundraiser: @fundraiser)
end

When("a donator goes to make a donation") do
  go_to_fundraiser(@fundraiser)
  click_on "Donate here!"
end

Then("they are notified that any overpayment will be considered a charitable gift") do
  expect(page).to have_content("By default any overpayment will be given directly to the charities.")
end

When("they make a donation double the price of the bundle") do
  make_donation(@bundle.total_value * 2)
end

Then("they are assigned {int} bundle(s)") do |count|
  go_to_assigned_bundles
  expect(page).to have_css(".assigned-bundles li", count:)
end

Given("a fundraiser in pro se mode") do
  @fundraiser = create(:fundraiser, :active, overpayment_mode: Fundraiser::PRO_SE)
  @bundle = create(:bundle, :live, fundraiser: @fundraiser)
end

Then("they are notified that any overpayment will be allocated to a new bundle") do
  expect(page).to have_content("You can have as many bundles as you like. By default any overpayment will go towards another bundle for you.")
end
