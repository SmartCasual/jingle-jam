# ## Schema Information
#
# Table name: `bundle_tiers`
#
# ### Columns
#
# Name                  | Type               | Attributes
# --------------------- | ------------------ | ---------------------------
# **`id`**              | `bigint`           | `not null, primary key`
# **`ends_at`**         | `datetime`         |
# **`name`**            | `string`           |
# **`price_currency`**  | `string`           | `default("GBP"), not null`
# **`price_decimals`**  | `integer`          | `default(0), not null`
# **`starts_at`**       | `datetime`         |
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

  delegate :fundraiser, to: :bundle

  def availability_text # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    return unless starts_at || ends_at

    if starts_at && starts_at > Time.now.utc
      if ends_at
        "Available between #{time(starts_at)} and #{time(ends_at)}"
      else
        "Available from #{time(starts_at)}"
      end
    elsif ends_at
      if ends_at > Time.now.utc
        "Available until #{time(ends_at)}"
      else
        "No longer available"
      end
    end
  end

private

  def time(datetime)
    format = if datetime.sec.zero?
      "%F %R (UTC)" # Don't include seconds
    else
      "%F %T (UTC)" # Do include seconds
    end

    datetime.utc.strftime(format)
  end
end
