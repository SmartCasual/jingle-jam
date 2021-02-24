class DonationsController < ApplicationController
  def new
    redirect_to donations_path
  end

  def index
    @donations = get_donations.order(created_at: :desc)
  end

  def create
    Donation.create!(donation_params.merge(donator: current_donator))

    if current_donator.persisted? && current_donator.previously_new_record?
      session[:donator_id] = current_donator.id
    end

    redirect_to donations_path
  end

private

  def get_donations
    return unless known_user?

    current_donator.donations || Donation.all
  end

  def donation_params
    params.require(:donation).permit(
      :amount,
      :message,
    )
  end
end
