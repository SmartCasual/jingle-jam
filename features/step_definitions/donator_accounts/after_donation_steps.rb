Then("they should be offered the ability to set up more ways to access their account") do
  click_on "Provide more information to more easily access your account and game keys"
  expect(page).to have_text("Login options")
end

Then("they are not offered the ability to set up more ways to access their account") do
  expect(page).not_to have_text("Provide more information to more easily access your account and game keys")
end

Then("they can provide that information via their account page") do
  within "header" do
    click_on Donator.last.display_name
  end
  click_on "Settings"
  expect(page).to have_text("Login options")
end
