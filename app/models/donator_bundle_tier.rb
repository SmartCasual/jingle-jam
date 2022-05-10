# ## Schema Information
#
# Table name: `donator_bundle_tiers`
#
# ### Columns
#
# Name                     | Type               | Attributes
# ------------------------ | ------------------ | ---------------------------
# **`id`**                 | `bigint`           | `not null, primary key`
# **`unlocked`**           | `boolean`          | `default(FALSE), not null`
# **`created_at`**         | `datetime`         | `not null`
# **`updated_at`**         | `datetime`         | `not null`
# **`bundle_tier_id`**     | `bigint`           | `not null`
# **`donator_bundle_id`**  | `bigint`           | `not null`
#
class DonatorBundleTier < ApplicationRecord
  belongs_to :bundle_tier
  belongs_to :donator_bundle

  has_many :keys, inverse_of: :donator_bundle_tier, dependent: :nullify
  has_many :assigned_games, through: :keys, source: :game

  scope :locked, -> { where(unlocked: false) }
  scope :unlocked, -> { where(unlocked: true) }
  scope :oldest_first, -> { order(updated_at: :asc) }
  scope :unfulfilled, -> {
    join_sql = <<~SQL.squish
      INNER JOIN bundle_tier_games ON bundle_tier_games.bundle_tier_id = donator_bundle_tiers.bundle_tier_id
      LEFT OUTER JOIN keys ON keys.game_id = bundle_tier_games.game_id
        AND keys.donator_bundle_tier_id = donator_bundle_tiers.id
    SQL

    distinct.joins(join_sql).where(keys: { id: nil })
  }
  scope :for_fundraiser, ->(fundraiser) do
    joins(bundle_tier: { bundle: :fundraiser })
    .where("bundles.fundraiser_id" => fundraiser.id)
  end

  delegate :price, to: :bundle_tier

  after_commit on: :create do
    trigger_fulfillment if unlocked?
  end

  after_commit on: :update do
    trigger_fulfillment if unlocked? && unlocked_previously_changed?
  end

  def unlock!
    update!(unlocked: true) if locked?
  end

  def locked?
    !unlocked?
  end

  def fulfilled?
    bundle_tier.bundle_tier_games.count == assigned_games.count
  end

private

  def trigger_fulfillment
    KeyAssignment::RequestProcessor.queue_fulfillment(self)
  end
end
