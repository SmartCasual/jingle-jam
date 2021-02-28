class AddUniqueIndexOnKey < ActiveRecord::Migration[6.1]
  def change
    add_index :keys, [:bundle_id, :game_id], unique: true, if_not_exists: true
  end
end
