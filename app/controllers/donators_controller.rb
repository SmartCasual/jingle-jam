class DonatorsController < ApplicationController
  load_resource
  authorize_resource(
    only: %i[
      show
    ],
  )

  def show
    redirect_to login_options_donator_path(@donator)
  end

  def request_login_email; end

  def log_in_via_token; end

  def login_options
    authorize! :edit, @donator
  end

  def update_login_options
    authorize! :edit, @donator

    @donator.assign_attributes(
      params.require(:donator).permit(
        :email_address,
        :password,
        :password_confirmation,
      ),
    )

    unless @donator.save
      flash[:alert] = @donator.full_messages.to_sentence
    end

    # Ordinarily Devise would do this, but we're
    # not in a Devise controller.
    if Devise.sign_in_after_change_password
      bypass_sign_in(@donator, scope: :donator)
    end

    if @donator.email_address_previously_changed?
      NotificationsMailer.account_created(@donator).deliver_later
    end

    redirect_to login_options_donator_path(@donator)
  end

  def disconnect_twitch
    authorize! :edit, @donator

    @donator.update(twitch_id: nil)

    redirect_to login_options_donator_path(@donator)
  end
end
