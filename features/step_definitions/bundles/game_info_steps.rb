When("a donator clicks on {string} in the bundle definition") do |game_name|
  go_to_homepage
  click_on game_name
end

Then("they should see {string} and its description") do |game_name|
  expect(page).to have_css("h2", text: game_name)
  expect(page).to have_text(Game.find_by!(name: game_name).description)
end
