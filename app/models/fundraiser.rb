# ## Schema Information
#
# Table name: `fundraisers`
#
# ### Columns
#
# Name                    | Type               | Attributes
# ----------------------- | ------------------ | ---------------------------
# **`id`**                | `bigint`           | `not null, primary key`
# **`description`**       | `text`             |
# **`ends_at`**           | `datetime`         |
# **`name`**              | `string`           | `not null`
# **`overpayment_mode`**  | `string`           | `default("pro_bono"), not null`
# **`short_url`**         | `string`           |
# **`starts_at`**         | `datetime`         |
# **`state`**             | `string`           | `default("inactive"), not null`
# **`created_at`**        | `datetime`         | `not null`
# **`updated_at`**        | `datetime`         | `not null`
#
class Fundraiser < ApplicationRecord
  has_many :bundle_definitions, inverse_of: :fundraiser, dependent: :nullify
  has_many :charity_fundraisers, inverse_of: :fundraiser, dependent: :destroy
  has_many :charities, through: :charity_fundraisers
  has_many :donations, inverse_of: :fundraiser, dependent: :nullify
  has_many :keys, inverse_of: :fundraiser, dependent: :destroy

  OVERPAYMENT_MODES = [
    PRO_BONO = "pro_bono".freeze,
    PRO_SE = "pro_se".freeze,
  ].freeze

  include AASM

  aasm column: :state do
    state :inactive, initial: true
    state :active
    state :archived

    event :activate do
      transitions from: :inactive, to: :active
    end

    event :reactivate do
      transitions from: :closed, to: :active
    end

    event :deactivate do
      transitions from: :active, to: :inactive
    end

    event :archive do
      transitions from: :inactive, to: :archived
    end
  end

  validates :name, presence: true
  validates :overpayment_mode, inclusion: { in: OVERPAYMENT_MODES }

  scope :open, -> {
    where("coalesce(starts_at, '1970-01-01 00:00') <= now() and now() <= coalesce(ends_at, '2999-12-31 23:59')")
  }

  def to_s
    name
  end
end
