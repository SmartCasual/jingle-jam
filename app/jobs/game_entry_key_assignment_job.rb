class GameEntryKeyAssignmentJob < ApplicationJob
  queue_as :default

  def perform(game_entry_id, bundle_id)
    game_entry = BundleDefinitionGameEntry.find_by(id: game_entry_id)
    bundle = Bundle.find_by(id: bundle_id)
    game = game_entry.game

    return unless game_entry && bundle && game

    return if already_assigned?(bundle, game_entry)
    return unless donation_level_met?(bundle, game_entry)

    # https://api.rubyonrails.org/v6.1.0/classes/ActiveRecord/Locking/Pessimistic.html
    # https://www.postgresql.org/docs/9.5/sql-select.html#SQL-FOR-UPDATE-SHARE
    Key.transaction do
      key = Key.lock("FOR UPDATE SKIP LOCKED").find_by(game: game, bundle: nil)
      key.update(bundle: bundle)
    end
  end

private

  def already_assigned?(bundle, game_entry)
    bundle.assigned_games.include?(game_entry.game)
  end

  def donation_level_met?(bundle, game_entry)
    total_donations = bundle.donator.total_donations

    total_donations >= bundle.bundle_definition.price || (game_entry.price.present? && total_donations >= game_entry.price)
  end
end
