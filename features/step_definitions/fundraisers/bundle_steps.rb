Given("a live bundle and a draft bundle for a fundraiser") do
  @fundraiser = create(:fundraiser, :active)
  @live_bundle = create(:bundle, :live, fundraiser: @fundraiser)
  @draft_bundle = create(:bundle, :draft, fundraiser: @fundraiser)
end

When("I visit the fundraiser's public page") do
  go_to_fundraiser(@fundraiser)
end

Then("I should see only the live bundle") do
  expect(page).to have_content(@live_bundle.name)
  expect(page).to_not have_content(@draft_bundle.name)
end
