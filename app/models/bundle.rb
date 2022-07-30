# ## Schema Information
#
# Table name: `bundles`
#
# ### Columns
#
# Name                 | Type               | Attributes
# -------------------- | ------------------ | ---------------------------
# **`id`**             | `bigint`           | `not null, primary key`
# **`aasm_state`**     | `string`           | `default("draft"), not null`
# **`name`**           | `string`           | `not null`
# **`created_at`**     | `datetime`         | `not null`
# **`updated_at`**     | `datetime`         | `not null`
# **`fundraiser_id`**  | `bigint`           | `not null`
#
class Bundle < ApplicationRecord
  belongs_to :fundraiser, inverse_of: :bundles

  has_many :bundle_tiers, inverse_of: :bundle, dependent: :destroy
  has_many :donator_bundles, inverse_of: :bundle, dependent: :nullify

  accepts_nested_attributes_for :bundle_tiers, allow_destroy: true

  validates :name, presence: true, uniqueness: { scope: :fundraiser_id }

  validate do
    if bundle_tiers.map(&:price_currency).uniq.count > 1
      errors.add(:base, "All bundle tiers must have the same currency")
    end
  end

  include AASM

  aasm do
    state :draft, initial: true
    state :live

    event :publish do
      transitions from: :draft, to: :live
    end

    event :retract do
      transitions from: :live, to: :draft
    end
  end

  after_commit on: :create do
    if bundle_tiers.none?
      bundle_tiers.create!(
        price_currency: fundraiser.main_currency,
      )
    end
  end

  def highest_tier
    bundle_tiers.max_by(&:price)
  end

  def lowest_tier
    bundle_tiers.min_by(&:price)
  end

  def total_value
    highest_tier.price
  end

  def currency
    highest_tier&.price_currency
  end
end
