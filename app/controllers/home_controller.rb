class HomeController < ApplicationController
  def home
    @bundle_definitions = BundleDefinition.order(:name)
    @charities = Charity.order(:name)
  end
end
