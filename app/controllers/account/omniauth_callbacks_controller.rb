class Account::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: [:token]

  def token
    if (donator = Donator.find_by(id: omniauth_uid))
      confirm_email_address(donator)
      log_in(donator)
    else
      head :not_found
    end
  end

  def twitch
    donator = Donator.find_by(twitch_id: omniauth_uid) ||
              Donator.find_by(email_address: omniauth_email_address) ||
              Donator.create_from_omniauth!(omniauth_hash)

    donator.update(twitch_id: omniauth_uid) if donator.twitch_id.blank?

    confirm_email_address(donator)
    log_in(donator)
  end

private

  def confirm_email_address(donator)
    return if omniauth_email_address.blank?

    donator.confirm if donator.email_address == omniauth_email_address
  end

  def log_in(donator)
    set_flash_message!(:notice, :signed_in)
    sign_in(donator, scope: :donator) unless donator_signed_in?
    redirect_to after_sign_in_path_for(donator)
  end

  def omniauth_hash
    request.env["omniauth.auth"]
  end

  def omniauth_uid
    omniauth_hash["uid"]
  end

  def omniauth_email_address
    omniauth_hash.dig("info", "email")
  end
end
