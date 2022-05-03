class AccountController < ApplicationController
  def show; end

  def request_login_email; end

  def send_login_email
    NotificationsMailer.token_url_request(params[:email_address]).deliver_later
    flash[:notice] = "A log in URL has been sent to #{params[:email_address]}."

    redirect_to request_login_email_account_path
  end

  def log_in_via_token; end

  def login_options; end

  def update_login_options
    current_donator.assign_attributes(
      params.require(:donator).permit(
        :email_address,
        :password,
        :password_confirmation,
      ),
    )

    unless current_donator.save
      flash[:alert] = current_donator.full_messages.to_sentence
    end

    # Ordinarily Devise would do this, but we're
    # not in a Devise controller.
    if Devise.sign_in_after_change_password
      bypass_sign_in(current_donator, scope: :donator)
    end

    if current_donator.email_address_previously_changed?
      NotificationsMailer.account_created(current_donator).deliver_later
    end

    redirect_to login_options_account_path
  end

  def disconnect_twitch
    current_donator.update(twitch_id: nil)

    redirect_to login_options_account_path
  end
end
