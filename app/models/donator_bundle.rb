# ## Schema Information
#
# Table name: `donator_bundles`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `bigint`           | `not null, primary key`
# **`created_at`**  | `datetime`         | `not null`
# **`updated_at`**  | `datetime`         | `not null`
# **`bundle_id`**   | `bigint`           | `not null`
# **`donator_id`**  | `bigint`           | `not null`
#
class DonatorBundle < ApplicationRecord
  belongs_to :donator
  belongs_to :bundle

  has_many :donator_bundle_tiers, dependent: :destroy
  has_many :keys, through: :donator_bundle_tiers

  def self.build_from(bundle, **attrs)
    new(bundle:, **attrs).tap do |donator_bundle|
      bundle.bundle_tiers.each do |bundle_tier|
        donator_bundle.donator_bundle_tiers.build(bundle_tier:)
      end
    end
  end

  def self.create_from(...)
    build_from(...).tap(&:save!)
  end

  def complete?
    unlockable_tiers.none?
  end

  def next_unlockable_tier
    unlockable_tiers.first
  end

  def unlockable_tiers_at_or_below(amount)
    unlockable_tiers.where("price_decimals <= ?", amount.fractional)
  end

private

  def unlockable_tiers
    donator_bundle_tiers.joins(:bundle_tier).locked.order(:price_decimals)
  end
end
