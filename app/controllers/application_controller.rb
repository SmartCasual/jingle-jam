class ApplicationController < ActionController::Base
private

  def current_donator
    @current_donator ||= (super || Donator.new)
  end

  attr_writer :current_donator

  def known_user?
    current_user.present?
  end

  def current_user
    current_admin_user || current_donator
  end

  def current_ability
    @current_ability ||= PublicAbility.new(current_donator)
  end

  def current_token_url
    log_in_via_token_account_url(current_donator, token: current_donator.token) if donator_logged_in?
  end
  helper_method :current_token_url

  def donator_signed_in?
    current_donator&.persisted?
  end
  alias_method :donator_logged_in?, :donator_signed_in?
  helper_method :donator_logged_in?

  def error(message)
    Rails.logger.error(message)
    render json: { errors: [message] }, status: :unprocessable_entity
  end

  def enforce_2sv
    session[:last_otp_at]
    redirect_to admin_otp_input_path unless session[:last_otp_at]
  end

  def twitch_embed_enabled?
    ENV.fetch("TWITCH_EMBED_ENABLED", "true") == "true"
  end
  helper_method :twitch_embed_enabled?
end
