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
# **`paypal_order_id`**           | `string`           |
# **`stripe_payment_intent_id`**  | `string`           |
#
class Payment < ApplicationRecord
  belongs_to :donation, optional: true, inverse_of: :payments

  class << self
    def create_and_assign(amount:, currency:, stripe_payment_intent_id: nil, paypal_order_id: nil)
      if stripe_payment_intent_id.nil? && paypal_order_id.nil?
        raise ArgumentError,
"Either stripe_payment_intent_id or paypal_order_id must be provided"
      end

      params = {
        amount_decimals: amount,
        amount_currency: currency,
      }

      if stripe_payment_intent_id
        unless (payment = Payment.find_by(stripe_payment_intent_id:))
          payment = Payment.create!(stripe_payment_intent_id:, **params)
        end

        PaymentAssignmentJob.perform_later(payment.id, provider: :stripe)
      else
        unless (payment = Payment.find_by(paypal_order_id:))
          payment = Payment.create!(paypal_order_id:, **params)
        end

        PaymentAssignmentJob.perform_later(payment.id, provider: :paypal)
      end
    end
  end
end
