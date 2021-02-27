class BundleCheckJob < ApplicationJob
  queue_as :default

  def perform(donator_id)
    return unless (donator = Donator.find_by(donator_id))

    # TODO: Assign bundle level based on total donations
  end
end
