module AccountTestHelpers
  def expect_logged_in(_donator)
    expect(page).not_to have_text("Invalid credentials")

    within "nav .donator" do
      expect(page).to have_content(@current_donator.display_name.upcase)
    end
    expect(page).to have_button("Log out")
  end

  def create_donator_account(email_address: "test@example.com", password: "password123", provider: :database)
    visit new_donator_registration_path

    case provider
    when :database
      fill_in "Email address", with: email_address
      fill_in "Password", with: password
      fill_in "Password confirmation", with: password

      click_button "Sign up"
    when :twitch
      click_on "Sign up wth Twitch"
    else
      raise "Unknown provider: #{provider}"
    end
  end

  def confirm_email_address
    email = email_with_subject("Confirmation instructions")
    visit find_link(email, /confirmation_token/)
    click_on "Confirm email address"
  end
end

World(AccountTestHelpers)
