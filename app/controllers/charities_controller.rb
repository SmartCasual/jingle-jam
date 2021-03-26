class CharitiesController < ApplicationController
  def show
    @charity = Charity.find(params[:id])
  end
end
