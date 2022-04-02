class KeyManager
  def key_assigned?(game, bundle:)
    bundle.assigned_games.include?(game)
  end

  def lock_unassigned_key(game)
    # https://api.rubyonrails.org/v6.1.0/classes/ActiveRecord/Locking/Pessimistic.html
    # https://www.postgresql.org/docs/9.5/sql-select.html#SQL-FOR-UPDATE-SHARE
    Key.transaction do
      yield Key.lock("FOR UPDATE SKIP LOCKED").find_by(
        game:,
        bundle: nil,
      )
    end
  end
end
