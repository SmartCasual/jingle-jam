class CuratedStreamersController < ApplicationController
  include Translated

  before_action :load_streamer
  before_action :check_admin, only: [:admin]

  helper DonationHelpers

  def show
    if (fundraiser_id = params[:fundraiser_id]).present?
      @fundraiser = Fundraiser.find(fundraiser_id)
    elsif Fundraiser.active.count == 1
      redirect_to fundraiser_curated_streamer_path(Fundraiser.active.first, @streamer)
    else
      redirect_to choose_fundraiser_curated_streamer_path(@streamer)
    end
  end

  def choose_fundraiser
    @fundraisers = Fundraiser.active
  end

  def admin; end

private

  def load_streamer
    @streamer = CuratedStreamer.find_by(params.permit(:twitch_username))
  end

  def check_admin
    redirect_to root_path unless @streamer.admins.include?(current_donator)
  end
end
