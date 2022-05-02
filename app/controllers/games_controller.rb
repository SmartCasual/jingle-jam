class GamesController < ApplicationController
  include Translated

  def show
    @game = Game.find(params[:id])
  end
end
