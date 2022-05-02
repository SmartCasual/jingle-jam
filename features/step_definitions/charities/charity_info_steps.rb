When("a donator clicks on {string} on the {string} fundraiser page") do |charity_name, fundraiser_name|
  go_to_fundraiser(name: fundraiser_name)
  click_on charity_name
end

Then("they should see the charity {string} and its description") do |charity_name|
  expect(page).to have_css("h2", text: charity_name)
  expect(page).to have_text(Charity.find_by!(name: charity_name).description)
end
