# ## Schema Information
#
# Table name: `charities`
#
# ### Columns
#
# Name               | Type               | Attributes
# ------------------ | ------------------ | ---------------------------
# **`id`**           | `bigint`           | `not null, primary key`
# **`description`**  | `text`             |
# **`name`**         | `string`           | `not null`
# **`created_at`**   | `datetime`         | `not null`
# **`updated_at`**   | `datetime`         | `not null`
#
class Charity < ApplicationRecord
  validates :name, presence: true

  has_many :charity_fundraisers, inverse_of: :charity, dependent: :destroy
  has_many :fundraisers, through: :charity_fundraisers
  has_many :charity_splits, inverse_of: :charity, dependent: :destroy
  has_many :donations, through: :charity_splits, inverse_of: :charities
end
