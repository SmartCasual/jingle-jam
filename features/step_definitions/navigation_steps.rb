When("a donator visits {string}") do |path|
  visit path
end

Then("they should see the header {string}") do |heading|
  expect(page).to have_css("h1", text: heading)
end

When("a donator clicks on {string}") do |link|
  click_on link
end

Then("they should be bounced to the admin login page") do
  expect(page).to have_css(".active_admin h2", text: "Jingle Jam Login")
end
