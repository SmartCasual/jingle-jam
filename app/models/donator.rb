# ## Schema Information
#
# Table name: `donators`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `bigint`           | `not null, primary key`
# **`name`**        | `string`           |
# **`created_at`**  | `datetime`         | `not null`
# **`updated_at`**  | `datetime`         | `not null`
#
class Donator < ApplicationRecord
  has_many :donations, inverse_of: :donator
  has_many :bundles, inverse_of: :donator

  def initialize(*args, anonymous: false)
    super(*args)


  end
end
