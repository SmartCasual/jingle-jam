# ## Schema Information
#
# Table name: `bundle_tier_games`
#
# ### Columns
#
# Name                  | Type               | Attributes
# --------------------- | ------------------ | ---------------------------
# **`id`**              | `bigint`           | `not null, primary key`
# **`created_at`**      | `datetime`         | `not null`
# **`updated_at`**      | `datetime`         | `not null`
# **`bundle_tier_id`**  | `bigint`           | `not null`
# **`game_id`**         | `bigint`           | `not null`
#
class BundleTierGame < ApplicationRecord
  belongs_to :bundle_tier
  belongs_to :game
end
