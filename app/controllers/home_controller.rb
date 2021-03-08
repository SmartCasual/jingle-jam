class HomeController < ApplicationController
  def home
    @bundle_definitions = BundleDefinition.order(:name)
  end
end
