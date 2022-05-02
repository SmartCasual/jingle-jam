class Account::ConfirmationsController < Devise::ConfirmationsController
  include Translated

  def show
    super if request.method == "POST"
  end

private

  def after_confirmation_path_for(_, resource)
    bypass_sign_in(resource, scope: :donator)
    super
  end
end
