Given("{int} unassigned keys for the game {string}") do |count, game_name|
  game = Game.find_by(name: game_name) || create(:game, name: game_name)
  create_list(:key, count, :unassigned, game:)
end

Given("{int} assigned keys for the game {string}") do |count, game_name|
  game = Game.find_by(name: game_name) || create(:game, name: game_name)
  create_list(:key, count, :assigned, game:)
end

Then("a summary should be available on the game index page") do
  go_to_admin_games

  row = page.find(".col-name", text: "Halo").ancestor("tr")
  within row do
    expect(page).to have_css(".col-unassigned_keys", text: "3")
    expect(page).to have_css(".col-assigned_keys", text: "2")
  end

  row = page.find(".col-name", text: "Fire Emblem").ancestor("tr")
  within row do
    expect(page).to have_css(".col-unassigned_keys", text: "2")
    expect(page).to have_css(".col-assigned_keys", text: "3")
  end
end

Then("a summary should be available on the game show page") do
  go_to_admin_game("Halo")
  expect(page).to have_css(".row-unassigned_keys", text: "3")
  expect(page).to have_css(".row-assigned_keys", text: "2")

  go_to_admin_game("Fire Emblem")
  expect(page).to have_css(".row-unassigned_keys", text: "2")
  expect(page).to have_css(".row-assigned_keys", text: "3")
end
