When("a donator visits {string}") do |path|
  visit path
end

Then("they should see the header {string}") do |heading|
  expect(page).to have_css("h1", text: heading)
end

When("a donator clicks on {string}") do |link|
  click_on link
end
