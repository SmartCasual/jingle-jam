# ## Schema Information
#
# Table name: `bundles`
#
# ### Columns
#
# Name                        | Type               | Attributes
# --------------------------- | ------------------ | ---------------------------
# **`id`**                    | `bigint`           | `not null, primary key`
# **`created_at`**            | `datetime`         | `not null`
# **`updated_at`**            | `datetime`         | `not null`
# **`bundle_definition_id`**  | `bigint`           | `not null`
# **`donator_id`**            | `bigint`           |
#
class Bundle < ApplicationRecord
  belongs_to :donator, optional: true
  belongs_to :bundle_definition
  has_many :keys
  has_many :assigned_games, through: :keys, source: :game

  delegate :bundle_definition_game_entries, to: :bundle_definition

  def assign_keys
    bundle_definition_game_entries.each do |game_entry|
      GameEntryKeyAssignmentJob.perform_later(game_entry.id, self.id)
      NotificationsMailer.bundle_assigned(donator).deliver_now
    end
  end
end
