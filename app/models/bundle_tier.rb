# ## Schema Information
#
# Table name: `bundle_tiers`
#
# ### Columns
#
# Name                  | Type               | Attributes
# --------------------- | ------------------ | ---------------------------
# **`id`**              | `bigint`           | `not null, primary key`
# **`name`**            | `string`           |
# **`price_currency`**  | `string`           | `default("GBP"), not null`
# **`price_decimals`**  | `integer`          | `default(0), not null`
# **`created_at`**      | `datetime`         | `not null`
# **`updated_at`**      | `datetime`         | `not null`
# **`bundle_id`**       | `bigint`           | `not null`
#
class BundleTier < ApplicationRecord
  monetize :price

  belongs_to :bundle, inverse_of: :bundle_tiers

  has_many :donator_bundle_tiers, inverse_of: :bundle_tier, dependent: :destroy
  has_many :bundle_tier_games, inverse_of: :bundle_tier, dependent: :destroy
  has_many :games, through: :bundle_tier_games

  accepts_nested_attributes_for :bundle_tier_games, allow_destroy: true
end
