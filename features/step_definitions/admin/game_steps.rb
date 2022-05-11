When("an admin adds a game") do
  game_name = "The Witness"

  go_to_admin_area "Games"
  click_on "New Game"
  fill_in "Name", with: game_name
  click_on "Create Game"

  @current_game = Game.find_by!(name: game_name)
end

Then("the game should appear on the admin games list") do
  go_to_admin_area "Games"
  expect(page).to have_css("td.col-name", text: @current_game.name)
end

Then("the game shouldn't appear on the admin games list") do
  go_to_admin_area "Games"
  expect(page).not_to have_css("td.col-name", text: @current_game.name)
end

Then("there should be an admin page for that game") do
  go_to_admin_game(@current_game)
  expect(page).to have_css("h2", text: @current_game.name)
end

Given("a game") do
  @current_game = FactoryBot.create(:game)
end

Given("a game with keys") do
  @current_game = FactoryBot.create(:game, :with_keys)
end

When("an admin adds keys to the game") do
  go_to_admin_game(@current_game, edit: true)

  @key_codes = [SecureRandom.uuid, SecureRandom.uuid]

  @key_codes.each do |key_code|
    click_on "Add New Key"
    fill_in "Code", with: key_code, currently_with: ""
  end

  click_on "Update Game"
end

When("the keys should be on the admin page for that game") do
  go_to_admin_game(@current_game)
  expect(page).to have_css(".row-unassigned_keys", text: @key_codes.count)
end

When("the key shouldn't be on the admin page for that game") do
  go_to_admin_game(@current_game)
  expect(page).to have_css(".row-unassigned_keys", text: @current_game.keys.count)
end

When("an admin edits the game") do
  go_to_admin_game(@current_game, edit: true)
  fill_in "Name", with: (@new_name = SecureRandom.uuid), fill_options: { clear: :backspace }
  click_on "Update Game"
end

When("an admin edits a key") do
  go_to_admin_game(@current_game, edit: true)
  fill_in "Code", with: (@new_code = SecureRandom.uuid), currently_with: @current_game.keys.first.code, fill_options: { clear: :backspace }
  click_on "Update Game"
end

Then("the edits to the game should've been saved") do
  go_to_admin_game(@current_game)
  expect(page).to have_css("h2", text: @new_name)
end

Then("the edits to the key should've been saved") do
  go_to_admin_game(@current_game)
  expect(@current_game.reload.keys.map(&:code)).to include(@new_code)
end

When("an admin deletes the game") do
  go_to_admin_area "Games"
  within "#game_#{@current_game.id}" do
    accept_confirm do
      click_on "Delete"
    end
  end
end

When("an admin deletes a key") do
  go_to_admin_game(@current_game, edit: true)

  fieldset = page.first(".keys fieldset")
  @deleted_code = fieldset.find("input[type='text']").value

  within fieldset do
    check "Delete"
  end

  click_on "Update Game"
end

When("the user goes to the admin games area") do
  visit admin_games_path
end
