class CuratedStreamersController < ApplicationController
  def show
    @streamer = CuratedStreamer.find_by(params.permit(:twitch_username))
  end
end
