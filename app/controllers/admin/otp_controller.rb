class Admin::OTPController < ApplicationController
  before_action :require_setup, only: %i[input]
  before_action :prevent_double_setup, only: %i[setup]
  before_action :require_otp_issuer

  def input; end

  def setup
    session[:otp_secret] = ROTP::Base32.random
    totp = ROTP::TOTP.new(session[:otp_secret], issuer: ENV["OTP_ISSUER"])
    @otp_url = totp.provisioning_uri(current_admin_user.email_address)
    @qr_code = RQRCode::QRCode.new(@otp_url).as_svg(standalone: false, module_size: 5)
  end

  def verify
    otp_secret = current_admin_user.otp_secret || session[:otp_secret]
    raise "Missing OTP secret" if otp_secret.blank?

    totp = ROTP::TOTP.new(otp_secret, issuer: ENV["OTP_ISSUER"], after: current_admin_user.last_otp_at)

    if totp.verify(params[:otp_code], drift_behind: 3)
      current_admin_user.otp_secret ||= session[:otp_secret]
      current_admin_user.update(last_otp_at: (session[:last_otp_at] = Time.zone.now))
      session[:otp_secret] = nil

      redirect_to admin_root_path
    elsif current_admin_user.has_2sv?
      redirect_to admin_otp_input_path
    else
      redirect_to admin_otp_setup_path
    end
  end

private

  def require_setup
    redirect_to admin_otp_setup_path unless current_admin_user&.has_2sv?
  end

  def prevent_double_setup
    redirect_to admin_otp_input_path if current_admin_user&.has_2sv?
  end

  def require_otp_issuer
    raise "Missing OTP issuer" if ENV["OTP_ISSUER"].blank?
  end
end
