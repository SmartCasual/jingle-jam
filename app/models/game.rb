# ## Schema Information
#
# Table name: `games`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `bigint`           | `not null, primary key`
# **`name`**        | `string`           | `not null`
# **`created_at`**  | `datetime`         | `not null`
# **`updated_at`**  | `datetime`         | `not null`
#
class Game < ApplicationRecord
  has_many :bundle_definition_game_entries, inverse_of: :games, dependent: :destroy
  has_many :keys, inverse_of: :game, dependent: :destroy

  validates :name, presence: true

  accepts_nested_attributes_for :keys, allow_destroy: true
end
