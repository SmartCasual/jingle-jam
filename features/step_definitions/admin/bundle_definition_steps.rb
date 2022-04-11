When("an admin adds a bundle definition") do
  bundle_definition_name = "Jingle Bundle"

  go_to_admin_area "Bundle Definitions"
  click_on "New Bundle Definition"
  fill_in "Name", with: bundle_definition_name
  click_on "Create Bundle definition"

  @current_bundle_definition = BundleDefinition.find_by!(name: bundle_definition_name)
end

Then("the bundle definition should appear on the admin bundle definitions list") do
  go_to_admin_area "Bundle Definitions"
  expect(page).to have_css("td.col-name", text: @current_bundle_definition.name)
end

Then("the bundle definition shouldn't appear on the admin bundle definitions list") do
  go_to_admin_area "Bundle Definitions"
  expect(page).not_to have_css("td.col-name", text: @current_bundle_definition.name)
end

Then("there should be an admin page for that bundle definition") do
  go_to_admin_bundle_definition(@current_bundle_definition)
  expect(page).to have_css("h2", text: @current_bundle_definition.name)
end

Given("a bundle definition") do
  @current_bundle_definition = FactoryBot.create(:bundle_definition)
end

Given("a bundle definition with tiers") do
  @current_bundle_definition = FactoryBot.create(:bundle_definition, :tiered)
end

Given("a {word} bundle definition") do |state|
  @current_bundle_definition = FactoryBot.create(:bundle_definition, state.to_sym)
end

Given("these games:") do |table|
  table.raw.each { |(name)| FactoryBot.create(:game, name:) }
end

When("an admin adds these games to the bundle definition:") do |table|
  go_to_admin_bundle_definition(@current_bundle_definition, edit: true)

  @game_entries = table.symbolic_hashes.map { |game_entry|
    tier_price = game_entry[:tier_price]
    game_entry[:tier_price] = (tier_price == "bundle price" ? nil : Monetize.parse(tier_price))
    game_entry
  }

  @game_entries.each do |game_entry|
    click_on "Add game entry"

    within ".bundle_definition_game_entries fieldset:last-of-type" do
      select game_entry[:game], from: "Game"

      if (tier_price = game_entry[:tier_price])
        select tier_price.currency.iso_code, from: "Currency"
        fill_in "Price", with: tier_price.format(symbol: false)
      end
    end
  end

  click_on "Update Bundle definition"
end

When("an admin edits a game entry") do
  @new_game = FactoryBot.create(:game).name
  go_to_admin_bundle_definition(@current_bundle_definition, edit: true)

  page.find("option[selected='selected']", text: @current_bundle_definition.games.first.name)
    .ancestor("select")
    .find("option", text: @new_game)
    .select_option

  click_on "Update Bundle definition"
end

Then("the edits to the game entry should've been saved") do
  go_to_admin_bundle_definition(@current_bundle_definition)
  expect(page).to have_css(".col-game", text: @new_game)
end

Then("the games with their tiers should be on the admin page for that bundle definition") do
  go_to_admin_bundle_definition(@current_bundle_definition)

  @game_entries.each do |game_entry|
    game = Game.find_by!(name: game_entry[:game])
    within "#bundle_definition_game_entry_#{game.id}" do
      expect(page).to have_css(".col-game", text: game.name)
      expect(page).to have_css(".col-price", text: game_entry[:tier_price]&.format(no_cents_if_whole: true))
    end
  end
end

Then("the game entry shouldn't be on the admin page for that bundle definition") do
  go_to_admin_bundle_definition(@current_bundle_definition)
  expect(page).not_to have_css(".col-game", text: @deleted_game_entry)
end

When("an admin deletes a game entry") do
  go_to_admin_bundle_definition(@current_bundle_definition, edit: true)

  fieldset = page.first(".bundle_definition_game_entries fieldset")
  @deleted_game_entry = fieldset.find("li:first-of-type option[selected='selected']").text

  within fieldset do
    check "Delete"
  end

  click_on "Update Bundle definition"
end

When("an admin edits the bundle definition") do
  go_to_admin_bundle_definition(@current_bundle_definition, edit: true)
  fill_in "Name", with: (@new_name = SecureRandom.uuid)
  click_on "Update Bundle definition"
end

Then("the edits to the bundle definition should've been saved") do
  go_to_admin_bundle_definition(@current_bundle_definition)
  expect(page).to have_css("h2", text: @new_name)
end

When("an admin deletes the bundle definition") do
  go_to_admin_area "Bundle Definitions"
  within "#bundle_definition_#{@current_bundle_definition.id}" do
    accept_confirm do
      click_on "Delete"
    end
  end
end

When("an admin publishes the bundle definition") do
  go_to_admin_area "Bundle Definitions"
  within "#bundle_definition_#{@current_bundle_definition.id}" do
    accept_confirm do
      click_on "Publish"
    end
  end
end

When("an admin retracts the bundle definition") do
  go_to_admin_area "Bundle Definitions"
  within "#bundle_definition_#{@current_bundle_definition.id}" do
    accept_confirm do
      click_on "Retract"
    end
  end
end

When("the user goes to the admin bundle definitions area") do
  visit admin_bundle_definitions_path
end

Then("the bundle definition should appear on the admin bundle definitions list as {word}") do |state|
  expect(page).to have_css("#bundle_definition_#{@current_bundle_definition.id} .col-state", text: state.humanize)
end

Then("the bundle definitions list should not have an edit link for that bundle definition") do
  visit admin_bundle_definitions_path
  expect(page).not_to have_css("#bundle_definition_#{@current_bundle_definition.id} .col-edit")
end

When("an admin attempts to edit the bundle definition anyway") do
  visit edit_admin_bundle_definition_path(@current_bundle_definition)
end

Then("the admin should be redirected to the bundle definitions list") do
  expect(page).to have_css("h2", text: "Bundle Definitions")
end

When("an admin changes the price of a game tier within a bundle definition") do
  go_to_admin_bundle_definition(@current_bundle_definition, edit: true)

  @game_entry = @current_bundle_definition.bundle_definition_game_entries.find { |entry| entry.price.present? }
  @new_price = @game_entry.price + Money.new(100, "USD")

  fieldset = page.find("option[selected='selected']", text: @game_entry.game.name).ancestor("fieldset.has_many_fields")
  within fieldset do
    select @new_price.currency.iso_code, from: "Currency"
    fill_in "Price", with: @new_price.format(symbol: false)
  end

  click_on "Update Bundle definition"
end

Then("the price of the game tier should've been saved") do
  go_to_admin_bundle_definition(@current_bundle_definition)
  expect(page).to have_css(".col-price", text: @new_price.format(no_cents_if_whole: true))
end
