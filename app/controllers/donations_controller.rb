class DonationsController < ApplicationController
  before_action :set_flash, only: :index

  def new
    redirect_to donations_path
  end

  def index
    @donations = get_donations.order(created_at: :desc)
  end

private

  def get_donations
    return unless known_user?

    current_donator.donations || Donation.all
  end

  def set_flash
    flash[:notice] = case params[:status]
    when "success"
      "Donation made, thank you!"
    when "cancelled"
      "Donation cancelled."
    end

    redirect_to donations_path
  end
end
