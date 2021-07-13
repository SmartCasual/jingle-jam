# ## Schema Information
#
# Table name: `donations`
#
# ### Columns
#
# Name                              | Type               | Attributes
# --------------------------------- | ------------------ | ---------------------------
# **`id`**                          | `bigint`           | `not null, primary key`
# **`aasm_state`**                  | `string`           | `default("pending"), not null`
# **`amount_currency`**             | `string`           | `default("GBP"), not null`
# **`amount_decimals`**             | `integer`          | `default(0), not null`
# **`message`**                     | `string`           |
# **`created_at`**                  | `datetime`         | `not null`
# **`updated_at`**                  | `datetime`         | `not null`
# **`curated_streamer_id`**         | `bigint`           |
# **`donated_by_id`**               | `bigint`           |
# **`donator_id`**                  | `bigint`           | `not null`
# **`stripe_checkout_session_id`**  | `string`           |
#
class Donation < ApplicationRecord
  belongs_to :donator, inverse_of: :donations
  belongs_to :donated_by, inverse_of: :donations, optional: true, class_name: "Donator"
  belongs_to :curated_streamer, inverse_of: :donations, optional: true

  has_many :charity_splits, inverse_of: :donation, dependent: :destroy
  accepts_nested_attributes_for :charity_splits

  before_save do
    if charity_splits.all? { |s| s.amount.zero? }
      self.charity_splits = []
    end
  end

  monetize :amount

  include AASM

  aasm do
    state :pending, initial: true
    state :cancelled
    state :paid
    state :fulfilled

    event :cancel do
      transitions from: :pending, to: :cancelled
    end

    event :confirm_payment do
      transitions from: :pending, to: :paid
    end

    event :fulfill do
      transitions from: :paid, to: :fulfilled
    end
  end

  def initialize(*_)
    super

    if charity_splits.none?
      Charity.all.find_each do |charity|
        charity_splits.build(charity: charity)
      end
    end
  end

  def charity_name
    charity&.name
  end

  def state
    aasm_state
  end
end
