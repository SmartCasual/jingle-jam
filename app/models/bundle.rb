# ## Schema Information
#
# Table name: `bundles`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `bigint`           | `not null, primary key`
# **`created_at`**  | `datetime`         | `not null`
# **`updated_at`**  | `datetime`         | `not null`
# **`donator_id`**  | `bigint`           |
#
class Bundle < ApplicationRecord
  has_many :donations

  scope :assigned, -> { where.not(donator_id: nil) }
end
