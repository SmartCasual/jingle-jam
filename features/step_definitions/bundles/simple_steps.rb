Given("a simple bundle priced at {amount}") do |amount|
  @current_bundle_definition = FactoryBot.create(:bundle_definition, :live, price: amount)
  expect(@current_bundle_definition.keys.unassigned).to exist
  expect(@current_bundle_definition.keys.assigned).not_to exist
end
