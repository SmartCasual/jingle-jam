When("an admin adds an admin user") do
  admin_user_email = "#{SecureRandom.uuid}@example.com"

  go_to_admin_users
  click_on "New Admin User"

  fill_in "Name", with: "An Admin"
  fill_in "Email", with: admin_user_email
  fill_in "Password", with: "password", exact: true
  fill_in "Password confirmation", with: "password"

  click_on "Create Admin user"

  @created_admin_user = AdminUser.find_by!(email: admin_user_email)
end

Then("the admin user should appear on the admin users list") do
  go_to_admin_users
  expect(page).to have_css("td.col-email", text: @created_admin_user.email)
end

Then("the admin user shouldn't appear on the admin users list") do
  go_to_admin_users
  expect(page).not_to have_css("td.col-email", text: @created_admin_user.email)
end

Then("there should be an admin page for that admin user") do
  go_to_admin_user(@created_admin_user)
  expect(page).to have_css("h2", text: @created_admin_user.name)
end

Given("an admin user") do
  @created_admin_user = FactoryBot.create(:admin_user)
end

When("an admin edits the admin user") do
  go_to_admin_user(@created_admin_user, edit: true)

  fill_in "Name", with: (@new_name = SecureRandom.uuid)
  fill_in "Password", with: (@new_password = SecureRandom.uuid), exact: true
  fill_in "Password confirmation", with: @new_password

  click_on "Update Admin user"
end

Then("the edits to the admin user should've been saved") do
  go_to_admin_user(@created_admin_user)
  expect(page).to have_css("h2", text: @new_name)
  expect(@created_admin_user.reload.valid_password?(@new_password)).to eq(true)
end

When("an admin deletes the admin user") do
  go_to_admin_users
  within "#admin_user_#{@created_admin_user.id}" do
    accept_confirm do
      click_on "Delete"
    end
  end
end

When("the user goes to the admin users area") do
  visit admin_admin_users_path
end
