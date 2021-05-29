require "hmac"

class SessionsController < ApplicationController
  def magic_redirect
    donator = Donator.find(params[:donator_id])

    if hmac_validator.validate(params[:hmac], against_id: donator.id)
      session[:donator_id] = donator.id
      redirect_to keys_path
    else
      head :unauthorized
    end
  end

  def logout
    reset_session
    redirect_to root_path
  end

private

  def hmac_validator
    @hmac_validator ||= HMAC::Validator.new(context: "sessions")
  end
end
