class Donators::ConfirmationsController < Devise::ConfirmationsController
  def show
    super if request.method == "POST"
  end
end
