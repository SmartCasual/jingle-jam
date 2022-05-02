# ## Schema Information
#
# Table name: `charity_fundraisers`
#
# ### Columns
#
# Name                 | Type               | Attributes
# -------------------- | ------------------ | ---------------------------
# **`id`**             | `bigint`           | `not null, primary key`
# **`created_at`**     | `datetime`         | `not null`
# **`updated_at`**     | `datetime`         | `not null`
# **`charity_id`**     | `bigint`           |
# **`fundraiser_id`**  | `bigint`           |
#
class CharityFundraiser < ApplicationRecord
  belongs_to :fundraiser, inverse_of: :charity_fundraisers
  belongs_to :charity, inverse_of: :charity_fundraisers
end
