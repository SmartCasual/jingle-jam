class DonatorBundleTierFulfillmentJob < ApplicationJob
  queue_as :default

  def initialize(*args, key_manager: nil)
    super(*args)

    @key_manager = key_manager || KeyManager.new
  end

  def perform(donator_bundle_tier_id) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    return if (donator_bundle_tier = DonatorBundleTier.find_by(id: donator_bundle_tier_id)).blank?
    return if donator_bundle_tier.locked?

    donator_bundle_tier.bundle_tier.games.each do |game|
      next if @key_manager.key_assigned?(game, donator_bundle_tier:)

      @key_manager.lock_unassigned_key(game) do |key|
        donator = donator_bundle_tier.donator_bundle.donator

        if key
          key.update!(donator_bundle_tier:)

          if donator.email_address.present? && donator.confirmed?
            NotificationsMailer.bundle_assigned(donator).deliver_now
          end
        else
          PanicMailer.missing_key(donator, game).deliver_now
        end
      end
    end
  end
end
