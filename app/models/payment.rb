# ## Schema Information
#
# Table name: `payments`
#
# ### Columns
#
# Name                            | Type               | Attributes
# ------------------------------- | ------------------ | ---------------------------
# **`id`**                        | `bigint`           | `not null, primary key`
# **`amount_currency`**           | `string`           | `default("GBP"), not null`
# **`amount_decimals`**           | `integer`          | `default(0), not null`
# **`created_at`**                | `datetime`         | `not null`
# **`updated_at`**                | `datetime`         | `not null`
# **`donation_id`**               | `bigint`           |
# **`stripe_payment_intent_id`**  | `string`           | `not null`
#
class Payment < ApplicationRecord
  belongs_to :donation, optional: true, inverse_of: :payments

  class << self
    def create_and_assign(amount:, currency:, stripe_payment_intent_id:)
      unless (payment = Payment.find_by(stripe_payment_intent_id:))
        payment = Payment.create!(
          amount_decimals: amount,
          amount_currency: currency,
          stripe_payment_intent_id:,
        )
      end

      PaymentAssignmentJob.perform_later(payment.id) if payment.donation.blank?
    end
  end
end
