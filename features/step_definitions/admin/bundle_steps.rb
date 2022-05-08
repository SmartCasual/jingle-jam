When("an admin adds a bundle") do
  bundle_name = "Test bundle"

  go_to_admin_area "Bundles"
  click_on "New Bundle"
  fill_in "Name", with: bundle_name
  select Fundraiser.active.first.name, from: "Fundraiser"
  click_on "Create Bundle"

  @current_bundle = Bundle.find_by!(name: bundle_name)
end

Then("the bundle should appear on the admin bundles list") do
  go_to_admin_area "Bundles"
  expect(page).to have_css("td.col-name", text: @current_bundle.name)
end

Then("the bundle shouldn't appear on the admin bundles list") do
  go_to_admin_area "Bundles"
  expect(page).not_to have_css("td.col-name", text: @current_bundle.name)
end

Then("there should be an admin page for that bundle") do
  go_to_admin_bundle(@current_bundle)
  expect(page).to have_css("h2", text: @current_bundle.name)
end

Given("a bundle priced at {amount}") do |price|
  @current_bundle = create(:bundle, :live, price:)
end

Given("a draft bundle priced at {amount}") do |price|
  @current_bundle = create(:bundle, :draft, price:)
end

Given("a bundle") do
  @current_bundle = create(:bundle, :live)
end

Given("a bundle with tiers") do
  @current_bundle = create(:bundle, :live, :tiered)
end

Given(/^a (draft|live) bundle$/) do |state|
  @current_bundle = create(:bundle, state.to_sym)
end

Given(/^a (draft|live) bundle with tiers$/) do |state|
  @current_bundle = create(:bundle, state.to_sym, :tiered)
end

Given("these games:") do |table|
  table.raw.each { |(name)| create(:game, name:) }
end

When("an admin adds these games to the bundle:") do |table|
  @tiers_and_games = table.symbolic_hashes.each.with_object(Hash.new { |h, k| h[k] = [] }) do |row, hash|
    hash[Monetize.parse(row[:tier])] << row[:game]
  end

  add_tiers_and_games_to_bundle(@tiers_and_games,
    bundle: @current_bundle,
    navigate: true,
  )

  click_on "Update Bundle"
end

When("an admin edits a game entry") do
  @new_game = create(:game).name
  go_to_admin_bundle(@current_bundle, edit: true)

  page.find("option[selected='selected']", text: @current_bundle.highest_tier.games.first.name)
    .ancestor("select")
    .find("option", text: @new_game)
    .select_option

  click_on "Update Bundle"
end

Then("the edits to the game entry should've been saved") do
  go_to_admin_bundle(@current_bundle)
  expect(page).to have_css(".row-games td", text: @new_game)
end

Then("the games with their tiers should be on the admin page for that bundle") do
  go_to_admin_bundle(@current_bundle)

  tier_blocks = page.all(".bundle_tier")

  @tiers_and_games.sort.reverse.each.with_index do |(tier_price, games), index|
    within tier_blocks[index] do
      expect(page).to have_css(".row-price td", text: tier_price.format(no_cents_if_whole: true))
      expect(page).to have_css(".row-games td", text: games.join(", "))
    end
  end
end

When("an admin deletes a game entry") do
  go_to_admin_bundle(@current_bundle, edit: true)

  fieldset = page.first(".bundle_tier_games > fieldset")
  @deleted_game_entry = fieldset.find("li:first-of-type option[selected='selected']").text

  within fieldset do
    check "Delete"
  end

  click_on "Update Bundle"
end

Then("the game entry shouldn't be on the admin page for that bundle") do
  go_to_admin_bundle(@current_bundle)
  expect(page).not_to have_css(".row-games td", text: @deleted_game_entry)
end

When("an admin edits the bundle") do
  go_to_admin_bundle(@current_bundle, edit: true)
  within "#bundle_name_input" do
    fill_in "Name", with: (@new_name = SecureRandom.uuid)
  end
  click_on "Update Bundle"
end

Then("the edits to the bundle should've been saved") do
  go_to_admin_bundle(@current_bundle)
  expect(page).to have_css("h2", text: @new_name)
end

When("an admin deletes the bundle") do
  go_to_admin_area "Bundles"
  within "#bundle_#{@current_bundle.id}" do
    accept_confirm do
      click_on "Delete"
    end
  end
end

When("an admin publishes the bundle") do
  go_to_admin_area "Bundles"
  within "#bundle_#{@current_bundle.id}" do
    accept_confirm do
      click_on "Publish"
    end
  end
end

When("an admin retracts the bundle") do
  go_to_admin_area "Bundles"
  within "#bundle_#{@current_bundle.id}" do
    accept_confirm do
      click_on "Retract"
    end
  end
end

When("the user goes to the admin bundles area") do
  visit admin_bundles_path
end

Then("the bundle should appear on the admin bundles list as {word}") do |state|
  expect(page).to have_css("#bundle_#{@current_bundle.id} .col-state", text: state.humanize)
end

Then("the bundles list should not have an edit link for that bundle") do
  visit admin_bundles_path
  expect(page).not_to have_css("#bundle_#{@current_bundle.id} .col-edit")
end

When("an admin attempts to edit the bundle anyway") do
  visit edit_admin_bundle_path(@current_bundle)
end

Then("the admin should be redirected to the bundles list") do
  expect(page).to have_css("h2", text: "Bundles")
end

When("an admin changes the price of a game tier within a bundle") do
  go_to_admin_bundle(@current_bundle, edit: true)

  tier = @current_bundle.highest_tier
  @new_price = tier.price + Money.new(100, "USD")

  within ".bundle_tiers > fieldset:first-of-type" do
    select @new_price.currency.iso_code, from: "Currency"
    fill_in "Price", with: @new_price.format(symbol: false), fill_options: { clear: :backspace }
  end

  click_on "Update Bundle"
end

Then("the price of the game tier should've been saved") do
  go_to_admin_bundle(@current_bundle)
  expect(page).to have_css(".row-price td", text: @new_price.format(no_cents_if_whole: true))
end

When("an admin deletes a tier within a bundle") do
  go_to_admin_bundle(@current_bundle, edit: true)

  within ".bundle_tiers > fieldset:last-of-type" do
    decimals = page
      .find("label", text: "Price").ancestor("li")
      .find("input").value

    currency = page
      .find("label", text: "Currency").ancestor("li")
      .find("select").value

    @deleted_tier_price = Money.new(decimals, currency)
  end

  within ".bundle_tiers > fieldset:last-of-type > ol > .has_many_delete" do
    check "Delete"
  end

  click_on "Update Bundle"
end

Then("the tier shouldn't appear on the admin page for that bundle") do
  go_to_admin_bundle(@current_bundle)
  expect(page).not_to have_css(".row-price td", text: @deleted_tier_price.format(no_cents_if_whole: true))
end
