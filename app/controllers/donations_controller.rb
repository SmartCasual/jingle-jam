class DonationsController < ApplicationController
  before_action :set_flash, only: :index

  def new
    redirect_to donations_path
  end

  def index
    @donations = get_donations.order(created_at: :desc)
    @magic_url = magic_redirect_url(donator_id: current_donator.id, hmac: current_donator.hmac) if current_donator.persisted?
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
    else
      return
    end

    redirect_to donations_path
  end
end
