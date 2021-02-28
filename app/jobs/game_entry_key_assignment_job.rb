class GameEntryKeyAssignmentJob < ApplicationJob
  queue_as :default

  def perform(game_entry_id, bundle_id)
    game_entry = GameEntry.find_by(game_entry_id)
    bundle = Bundle.find_by(bundle_id)
    donator = bundle.donator
    game = game_entry.game

    next unless game_entry && bundle && donator && game

    next if already_assigned?(bundle, game_entry)
    next unless donation_level_met?(bundle, game_entry)

    # https://api.rubyonrails.org/v6.1.0/classes/ActiveRecord/Locking/Pessimistic.html
    # https://www.postgresql.org/docs/9.5/sql-select.html#SQL-FOR-UPDATE-SHARE
    Key.where(game: game, bundle: nil).with_lock("FOR UPDATE SKIP LOCKED") do |key|
      key.update(bundle: bundle)
    end
  end

private

  def already_assigned?(bundle, game_entry)
    bundle.assigned_games.include?(game_entry.game)
  end

  def donation_level_met?(bundle, game_entry)
    total_donations = donator.total_donations

    total_donations >= bundle.bundle_definition.price || (game_entry.price.present? && total_donations >= game_entry.price)
  end
end
