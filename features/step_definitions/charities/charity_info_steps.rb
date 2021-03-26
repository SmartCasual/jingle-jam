When("a donator clicks on {string} on the homepage") do |charity_name|
  go_to_homepage
  click_on charity_name
end

Then("they should see the charity {string} and its description") do |charity_name|
  expect(page).to have_css("h2", text: charity_name)
  expect(page).to have_text(Charity.find_by!(name: charity_name).description)
end
