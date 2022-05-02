module LoginHelpers
  def log_in_admin_with(email_address, otp_secret:, navigate: true, expect_failure: false)
    visit "/admin/login" if navigate

    fill_in "Email address", with: email_address
    fill_in "Password", with: "password123"
    click_on "Login"

    complete_2sv(otp_secret) if otp_secret.present?

    unless expect_failure
      @current_admin_user = AdminUser.find_by!(email_address:)
      expect(page).to have_css("#current_user a", text: @current_admin_user.name)
      @current_admin_user
    end
  end

  def log_in_donator_with(email_address:, password:, navigate: true, expect_failure: false)
    click_on "Log in" if navigate

    fill_in "Email", with: email_address
    fill_in "Password", with: password
    click_button "Log in"

    if expect_failure
      expect(page).to have_text("Invalid")
      expect(logged_in?).to be(false)
    else
      expect(logged_in?).to be(true)
    end
  end

  def complete_2sv(otp_secret)
    fill_in "112233", with: ROTP::TOTP.new(otp_secret).at(Time.zone.now)
    click_on "Verify"
  end

  def log_in_as(user_or_factory, traits: nil, **kwargs)
    user = case user_or_factory
    when Symbol
      FactoryBot.create(user_or_factory, *traits)
    when AdminUser, Donator
      user_or_factory
    else
      raise ArgumentError, "Please provide an `AdminUser`/`Donator` instance, or a factory name."
    end

    case user
    when Donator
      use_magic_link(user)
    when AdminUser
      log_in_admin_with(user.email_address, otp_secret: user.otp_secret, **kwargs)
    end

    user
  end

  def use_magic_link(donator)
    visit log_in_via_token_account_path(donator, token: donator.token)
    click_on "Log in via token"
    @current_donator = donator
    expect(logged_in?).to be(true)
  end

  def ensure_logged_in(as: :donator, **kwargs)
    log_in_as(as, **kwargs)
  end

  def log_out(navigate: true)
    go_to_homepage if navigate
    click_on "Log out"
  end

  def ensure_logged_out
    log_out if logged_in?
  end

  def logged_in?
    page.has_button?("Log out")
  end
end

World(LoginHelpers)
