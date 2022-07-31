Given("one active fundraiser") do
  @first_active_fundraiser = create(:fundraiser, :active)
end

Given("a second active fundraiser") do
  @second_active_fundraiser = create(:fundraiser, :active)
end

Given("no active fundraisers") do
  Fundraiser.active.destroy_all
end
