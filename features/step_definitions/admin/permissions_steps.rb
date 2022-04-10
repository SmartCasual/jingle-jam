Given("the admin has individual permissions") do
  @admin = FactoryBot.create(:admin_user,
    data_entry: true,
    manages_users: true,
    support: true,
    full_access: false,
  )
end

Then("a list of the permissions appears on the admin users page") do
  log_in_as(@admin)
  visit admin_admin_users_path
  expect(page).to have_content("Data entry, manages users, and support")
end

When("the admin is given full access") do
  @admin.update(full_access: true)
end

Then(%(the permissions list shows "Full access")) do
  visit admin_admin_users_path
  expect(page).to have_content("Full access")
  expect(page).not_to have_content("manages users")
end

Given("an admin with no permissions") do
  @subject_admin = FactoryBot.create(:admin_user,
    data_entry: false,
    manages_users: false,
    support: false,
    full_access: false,
  )
end

Given("an admin with permission to manage users") do
  @managing_admin = FactoryBot.create(:admin_user,
    manages_users: true,
    full_access: false,
  )
end

Then("the managing admin should be able to grant the other admin new permissions") do
  log_in_as(@managing_admin)
  visit admin_admin_users_path

  within("#admin_user_#{@subject_admin.id}") do
    click_on "Edit"
  end

  check "Manages users"
  click_on "Update Admin user"
  expect(page).to have_content("Admin user was successfully updated")

  visit admin_admin_users_path
  within("#admin_user_#{@subject_admin.id}") do
    expect(page).to have_content("Manages users")
  end
end

Then("the managing admin should be able to remove permissions from the other admin") do
  within("#admin_user_#{@subject_admin.id}") do
    click_on "Edit"
  end

  uncheck "Manages users"
  click_on "Update Admin user"
  expect(page).to have_content("Admin user was successfully updated")

  visit admin_admin_users_path
  within("#admin_user_#{@subject_admin.id}") do
    expect(page).not_to have_content("Manages users")
  end
end
