class DonatorsController < ApplicationController
  load_and_authorize_resource

  def show; end

  def edit; end

  def update
    @donator.assign_attributes(donator_params)

    unless @donator.save
      flash[:alert] = @donator.full_messages.to_sentence
    end

    redirect_to donator_path(@donator)
  end
end
