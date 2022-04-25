class DonationsController < ApplicationController
  before_action :set_flash, only: :index

  helper DonationHelpers

  def new
    redirect_to donations_path
  end

  def index
    @donations = get_donations.order(created_at: :desc)
    @gifted_donations = get_donations(gifted: true).order(created_at: :desc)

    if current_donator.persisted?
      @magic_url = log_in_via_token_donator_url(current_donator, token: current_donator.token)
    end
  end

private

  def get_donations(gifted: false)
    return unless known_user?

    if gifted
      current_donator.gifted_donations
    else
      current_donator.donations
    end
  end

  def set_flash
    flash[:notice] = case params[:status]
    when "success"
      "Donation made, thank you!"
    when "cancelled"
      "Donation cancelled."
    else
      return
    end

    if params[:streamer]
      redirect_to curated_streamer_path(twitch_username: params[:streamer])
    else
      redirect_to donations_path
    end
  end
end
