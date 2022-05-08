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

private

  def trigger_fulfillment
    DonatorBundleTierFulfillmentJob.perform_later(id)
  end
end
