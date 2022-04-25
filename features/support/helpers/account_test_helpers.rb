module AccountTestHelpers
  def expect_logged_in(_donator)
    expect(page).not_to have_text("Invalid credentials")

    within "nav .donator" do
      expect(page).to have_content(@current_donator.display_name.upcase)
    end
    expect(page).to have_button("Log out")
  end
end

World(AccountTestHelpers)
