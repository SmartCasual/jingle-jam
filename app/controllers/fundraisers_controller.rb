class FundraisersController < ApplicationController
  include Translated

  def index; end

  def show
    @fundraiser = Fundraiser.find(params[:id])
    @tiers_by_bundle = @fundraiser.bundles.live.each.with_object({}) do |bundle, hash|
      hash[bundle] = bundle.bundle_tiers.group_by(&:price).sort
    end
  end
end
