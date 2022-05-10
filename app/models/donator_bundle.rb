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
    locked_tiers.none?
  end

  def next_unlockable_tier
    unlockable_tiers.first
  end

  def unlockable_tiers_at_or_below(amount)
    unlockable_tiers.where("price_decimals <= ?", amount.fractional)
  end

private

  def locked_tiers
    donator_bundle_tiers.locked
  end

  def unlockable_tiers
    window_sql = <<~SQL.squish
      (bundle_tiers.starts_at IS NULL OR bundle_tiers.starts_at <= :now)
      AND (bundle_tiers.ends_at IS NULL OR bundle_tiers.ends_at > :now)
    SQL

    locked_tiers
      .joins(:bundle_tier)
      .order(:price_decimals)
      .where(window_sql, now: Time.now.utc)
  end
end
