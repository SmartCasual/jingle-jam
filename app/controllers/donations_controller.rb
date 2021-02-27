class DonationsController < ApplicationController
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
end
