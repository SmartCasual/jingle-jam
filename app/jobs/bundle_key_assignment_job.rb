class BundleKeyAssignmentJob < ApplicationJob
  queue_as :default

  def perform(bundle_id)
    Bundle.find_by(id: bundle_id)&.assign_keys
  end
end
