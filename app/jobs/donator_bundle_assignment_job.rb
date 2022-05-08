class DonatorBundleAssignmentJob < ApplicationJob
  queue_as :default

  def perform(donator_id)
    if (donator = Donator.find_by(id: donator_id)).blank?
      Rollbar.error("Donator not found", donator_id:)
      return
    end

    Fundraiser.active.open.each do |fundraiser|
      next if (total_donations = donator.total_donations(fundraiser:)).zero?

      fundraiser.bundles.each do |bundle|
        DonatorBundleAssigner.assign(donator:, bundle:, fund: total_donations) if bundle.live?
      end
    end
  end
end
