class KeyAssignment::KeyManager
  def key_assigned?(game, donator_bundle_tier:)
    donator_bundle_tier.assigned_games.include?(game)
  end

  def lock_unassigned_key(game, fundraiser: nil)
    # https://api.rubyonrails.org/v6.1.0/classes/ActiveRecord/Locking/Pessimistic.html
    # https://www.postgresql.org/docs/9.5/sql-select.html#SQL-FOR-UPDATE-SHARE
    Key.transaction do
      yield unassigned_key(game, fundraiser:)
    end
  end

private

  def unassigned_key(game, fundraiser: nil)
    if fundraiser && (key = scope(game).find_by(fundraiser:))
      key
    else
      scope(game).find_by(fundraiser: nil)
    end
  end

  def scope(game)
    Key.lock("FOR UPDATE SKIP LOCKED").where(
      game:,
      donator_bundle_tier: nil,
    )
  end
end
