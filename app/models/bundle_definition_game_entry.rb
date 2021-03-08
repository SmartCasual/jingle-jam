# ## Schema Information
#
# Table name: `bundle_definition_game_entries`
#
# ### Columns
#
# Name                        | Type               | Attributes
# --------------------------- | ------------------ | ---------------------------
# **`id`**                    | `bigint`           | `not null, primary key`
# **`price_currency`**        | `string`           |
# **`price_decimals`**        | `integer`          |
# **`created_at`**            | `datetime`         | `not null`
# **`updated_at`**            | `datetime`         | `not null`
# **`bundle_definition_id`**  | `bigint`           | `not null`
# **`game_id`**               | `bigint`           | `not null`
#
class BundleDefinitionGameEntry < ApplicationRecord
  belongs_to :bundle_definition
  belongs_to :game

  monetize :price, allow_nil: true

  after_commit :update_assignments, on: [:update]

  scope :simple, -> { where(price_currency: nil) }
  scope :tiered, -> { where.not(price_currency: nil) }

private

  def update_assignments
    bundle_definition.update_assignments
  end
end
