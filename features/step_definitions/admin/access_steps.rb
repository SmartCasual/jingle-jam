Given("at least one of each type of thing") do
  @current = %I[
    admin_comment
    admin_user
    bundle
    bundle_definition
    donation
    donator
    game
  ].index_with { |factory|
    FactoryBot.create(factory)
  }
end

Then("the admin should be able to see public information") do
  go_to_admin_games
  expect(page).to have_text(@current[:game].name)
end

Then("the admin should be able to comment on public information") do
  go_to_admin_game(@current[:game])
  add_comment("This is a fun game")
  reload_page
  expect(page).to have_text("This is a fun game")
end

Then("the admin should be able to see their own information") do
  expect(page).not_to have_text(@current_admin_user.email_address)

  within "#current_user" do
    click_on @current_admin_user.name
  end

  expect(page).to have_text(@current_admin_user.email_address)
end

Then("the admin should not be able to modify public information") do
  go_to_admin_game(@current[:game])
  expect(page).not_to have_text("Edit Game")
end

Then("the admin should be able to modify public information") do
  go_to_admin_game(@current[:game])
  expect(page).to have_text("Edit Game")
end

Then("the admin should not be able to read donation information") do
  go_to_admin_homepage
  expect(page).not_to have_text("Donations")
  visit admin_donations_path
  expect(page).to have_current_path(admin_root_path)
  expect(page).to have_text("You are not authorized to perform this action.")
end

Then("the admin should be able to read donation information") do
  go_to_admin_homepage
  expect(page).to have_text("Donations")
  click_on "Donations"
  expect(page).to have_current_path(admin_donations_path)
end

Then("the admin should not be able to manage admin accounts") do
  go_to_admin_users

  expect(page).not_to have_text(@current[:admin_user].email_address)
  expect(page).not_to have_text("Edit")

  visit admin_admin_user_path(@current[:admin_user])
  expect(page).to have_current_path(admin_root_path)
  expect(page).to have_text("You are not authorized to perform this action.")
end

Then("the admin should be able to manage admin accounts") do
  go_to_admin_users

  expect(page).to have_text(@current[:admin_user].email_address)
  expect(page).to have_text("Edit")

  visit admin_admin_user_path(@current[:admin_user])
  expect(page).to have_current_path(admin_admin_user_path(@current[:admin_user]))
end
