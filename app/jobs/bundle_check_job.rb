class BundleCheckJob < ApplicationJob
  queue_as :default

  def perform(donator_id)
    Donator.find_by(id: donator_id)&.assign_keys
  end
end
