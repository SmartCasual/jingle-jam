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

  def donator_signed_in?
    current_donator&.persisted?
  end
  alias_method :donator_logged_in?, :donator_signed_in?
  helper_method :donator_logged_in?

  around_action :switch_locale
  def switch_locale(&)
    locale = params[:locale] || I18n.default_locale
    I18n.with_locale(locale, &)
  end

  def default_url_options
    { locale: I18n.locale }
  end

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
