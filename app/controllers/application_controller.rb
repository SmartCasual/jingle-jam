class ApplicationController < ActionController::Base
private

  def current_donator
    @current_donator ||= Donator.find_by(id: session[:donator_id]) || Donator.new
  end
  helper_method :current_donator

  def known_user?
    current_user.present?
  end

  def current_user
    current_admin_user || current_donator
  end

  def error(message)
    Rails.logger.error(message)
    render json: { errors: [message] }, status: :unprocessable_entity
  end

  def enforce_2sv
    session[:last_otp_at]
    redirect_to admin_otp_input_path unless session[:last_otp_at]
  end
end
