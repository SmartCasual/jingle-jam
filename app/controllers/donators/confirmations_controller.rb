class Donators::ConfirmationsController < Devise::ConfirmationsController
  def show
    super if request.method == "POST"
  end

private

  def after_confirmation_path_for(_, resource)
    bypass_sign_in(resource, scope: :donator)
    super
  end
end
