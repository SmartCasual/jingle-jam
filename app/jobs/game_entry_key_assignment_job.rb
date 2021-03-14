class GameEntryKeyAssignmentJob < ApplicationJob
  queue_as :default

  def initialize(*args, key_manager: nil, tier_checker: nil)
    super(*args)

    @key_manager = key_manager || KeyManager.new
    @tier_checker = tier_checker || TierChecker.new
  end

  def perform(game_entry_id, bundle_id) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
    game_entry = BundleDefinitionGameEntry.find_by(id: game_entry_id)
    bundle = Bundle.find_by(id: bundle_id)

    return unless game_entry && bundle

    game = game_entry.game
    return unless game

    donator = bundle.donator
    return unless donator

    return if @key_manager.key_assigned?(game, bundle: bundle)
    return unless @tier_checker.donation_level_met?(game_entry, donator: donator)

    @key_manager.lock_unassigned_key(game) do |key|
      if key
        key.update(bundle: bundle)
        NotificationsMailer.bundle_assigned(donator).deliver_now
      else
        PanicMailer.missing_key(donator, game).deliver_now
      end
    end
  end
end
