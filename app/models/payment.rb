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
end
