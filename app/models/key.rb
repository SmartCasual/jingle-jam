# ## Schema Information
#
# Table name: `keys`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `bigint`           | `not null, primary key`
# **`code`**        | `string`           | `not null`
# **`created_at`**  | `datetime`         | `not null`
# **`updated_at`**  | `datetime`         | `not null`
# **`bundle_id`**   | `bigint`           |
# **`game_id`**     | `bigint`           | `not null`
#
class Key < ApplicationRecord
  belongs_to :game, inverse_of: :keys
  belongs_to :bundle, inverse_of: :keys, optional: true

  validates :code, presence: true

  scope :unassigned, -> { where(bundle: nil) }
  scope :assigned, -> { where.not(bundle: nil) }

  def assigned?
    bundle_id.present?
  end
end
