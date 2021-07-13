# ## Schema Information
#
# Table name: `charity_splits`
#
# ### Columns
#
# Name                   | Type               | Attributes
# ---------------------- | ------------------ | ---------------------------
# **`id`**               | `bigint`           | `not null, primary key`
# **`amount_currency`**  | `string`           | `default("GBP"), not null`
# **`amount_decimals`**  | `integer`          | `default(0), not null`
# **`created_at`**       | `datetime`         | `not null`
# **`updated_at`**       | `datetime`         | `not null`
# **`charity_id`**       | `bigint`           |
# **`donation_id`**      | `bigint`           |
#
class CharitySplit < ApplicationRecord
  belongs_to :donation, inverse_of: :charity_splits
  belongs_to :charity, inverse_of: :charity_splits

  monetize :amount
end
