# ## Schema Information
#
# Table name: `donations`
#
# ### Columns
#
# Name                   | Type               | Attributes
# ---------------------- | ------------------ | ---------------------------
# **`id`**               | `bigint`           | `not null, primary key`
# **`amount_currency`**  | `string`           | `default("GBP"), not null`
# **`amount_decimals`**  | `integer`          | `default(0), not null`
# **`message`**          | `string`           |
# **`created_at`**       | `datetime`         | `not null`
# **`updated_at`**       | `datetime`         | `not null`
# **`bundle_id`**        | `bigint`           |
# **`donated_by_id`**    | `bigint`           |
# **`donator_id`**       | `bigint`           | `not null`
#
class Donation < ApplicationRecord
  belongs_to :donator, inverse_of: :donations
  belongs_to :bundle, inverse_of: :donations, optional: true
  belongs_to :donated_by, inverse_of: :donations, optional: true

  monetize :amount_decimals
end
