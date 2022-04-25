class DonatorsController < ApplicationController
  load_and_authorize_resource(
    except: %i[
      log_in_via_token
      request_login_email
    ],
  )

  def show; end

  def edit; end

  def update
    @donator.assign_attributes(donator_params)

    unless @donator.save
      flash[:alert] = @donator.full_messages.to_sentence
    end

    redirect_to donator_path(@donator)
  end

  def request_login_email; end

  def log_in_via_token; end
end
