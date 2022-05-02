class Account::DonationsController < ApplicationController
  include Translated

  def index
    @donations = current_donator.donations.order(created_at: :desc)
    @gifted_donations = current_donator.gifted_donations.order(created_at: :desc)
  end
end
