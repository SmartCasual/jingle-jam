When("a donator visits {string}") do |path|
  visit path
end

Then("they should see the header {string}") do |heading|
  expect(page).to have_css("h1", text: heading)
end

When("a donator clicks on nav link {string}") do |link|
  within "nav" do
    click_on link
  end
end

When("a donator clicks on the main logo") do
  within "nav" do
    click_on "The Jingle Jam"
  end
end

Then("they should be bounced to the admin login page") do
  expect(page).to have_css(".active_admin h2", text: "Jingle Jam Login")
end
