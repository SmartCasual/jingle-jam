class CuratedStreamersController < ApplicationController
  before_action :load_streamer
  before_action :check_admin, only: [:admin]

  def show; end

  def admin; end

private

  def load_streamer
    @streamer = CuratedStreamer.find_by(params.permit(:twitch_username))
  end

  def check_admin
    redirect_to root_path unless @streamer.admins.include?(current_donator)
  end
end
