module DonatorRequired
  extend ActiveSupport::Concern

  included do
    before_action :require_current_donator
  end

  def require_current_donator
    redirect_to new_donator_sessions_path unless donator_logged_in?
  end
end
