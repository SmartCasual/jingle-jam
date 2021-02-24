# ## Schema Information
#
# Table name: `bundle_definitions`
#
# ### Columns
#
# Name                  | Type               | Attributes
# --------------------- | ------------------ | ---------------------------
# **`id`**              | `bigint`           | `not null, primary key`
# **`name`**            | `string`           | `not null`
# **`price_currency`**  | `string`           | `default("GBP"), not null`
# **`price_decimals`**  | `integer`          | `default(0), not null`
# **`created_at`**      | `datetime`         | `not null`
# **`updated_at`**      | `datetime`         | `not null`
#
class BundleDefinition < ApplicationRecord
  monetize :price_decimals
end
