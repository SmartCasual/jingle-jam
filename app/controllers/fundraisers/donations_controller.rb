class Fundraisers::DonationsController < ApplicationController
  include Translated

  helper DonationHelpers

  def new
    @fundraiser = Fundraiser.find(params[:fundraiser_id])
    @streamer = CuratedStreamer.find_by(twitch_username: params[:streamer]) if params[:streamer]
  end

  def index
    @fundraiser = Fundraiser.find(params[:fundraiser_id])
    @streamer = CuratedStreamer.find_by(twitch_username: params[:streamer]) if params[:streamer]

    set_flash_and_redirect_maybe

    @donations = get_donations.order(created_at: :desc)
    @gifted_donations = get_donations(gifted: true).order(created_at: :desc)
  end

private

  def get_donations(gifted: false)
    return unless known_user?

    if gifted
      current_donator.gifted_donations.where(fundraiser: @fundraiser)
    else
      current_donator.donations.where(fundraiser: @fundraiser)
    end
  end

  def set_flash_and_redirect_maybe
    flash[:notice] = case params[:status]
    when "success"
      "Donation made, thank you!"
    when "cancelled"
      current_donator.donations.pending.order(:id).last.destroy
      "Donation cancelled."
    else
      return
    end

    if @streamer
      redirect_to fundraiser_curated_streamer_path(@fundraiser, @streamer)
    else
      redirect_to fundraiser_donations_path(@fundraiser)
    end
  end
end
