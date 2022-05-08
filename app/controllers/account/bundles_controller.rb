class Account::BundlesController < ApplicationController
  include Translated
  include DonatorRequired

  def index
    @bundles_by_fundraiser = current_donator
      .donator_bundles
      .includes(bundle: :fundraiser)
      .group_by { |b| b.bundle.fundraiser }
  end

  def show
    @bundle = current_donator.donator_bundles.find(params[:id])
  end
end
