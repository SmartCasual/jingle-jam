class FundraisersController < ApplicationController
  include Translated

  def index; end

  def show
    @fundraiser = Fundraiser.find(params[:id])
  end
end
