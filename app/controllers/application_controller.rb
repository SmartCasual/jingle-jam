class ApplicationController < ActionController::Base

private

  def current_donator
    @current_donator ||= Donator.find_by(id: session[:donator_id]) || Donator.new(anonymous: true)
  end

  def current_admin

  end

  def known_user?
    current_donator || current_admin
  end
end
