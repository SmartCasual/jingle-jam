class HomeController < ApplicationController
  def home
    @bundle_definitions = BundleDefinition.order(:name)
  end

  def magic_redirect
    donator = Donator.find(params[:donator_id])

    if params[:hmac].present && params[:hmac] == hmac
      session[:donator_id] = donator.id
      redirect_to keys_path
    else
      head :unauthorized
    end
  end
end
