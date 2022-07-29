class KeyAssignment::KeyAssigner
  def initialize(key_manager: nil)
    @key_manager = key_manager || KeyAssignment::KeyManager.new
  end

  def assign(donator_bundle_tier, fundraiser: nil) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    return if donator_bundle_tier.nil?
    return if donator_bundle_tier.locked?

    fundraiser ||= donator_bundle_tier.bundle_tier.fundraiser

    donator_bundle_tier.bundle_tier.games.each do |game|
      next if @key_manager.key_assigned?(game, donator_bundle_tier:)

      @key_manager.lock_unassigned_key(game, fundraiser:) do |key|
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
  rescue Aws::SES::Errors::MessageRejected => e
    Rollbar.error(e)
  end
end
