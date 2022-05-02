# ## Schema Information
#
# Table name: `bundle_definitions`
#
# ### Columns
#
# Name                  | Type               | Attributes
# --------------------- | ------------------ | ---------------------------
# **`id`**              | `bigint`           | `not null, primary key`
# **`aasm_state`**      | `string`           | `default("draft"), not null`
# **`name`**            | `string`           | `not null`
# **`price_currency`**  | `string`           | `default("GBP"), not null`
# **`price_decimals`**  | `integer`          | `default(0), not null`
# **`created_at`**      | `datetime`         | `not null`
# **`updated_at`**      | `datetime`         | `not null`
# **`fundraiser_id`**   | `bigint`           |
#
class BundleDefinition < ApplicationRecord
  include AASM

  monetize :price

  belongs_to :fundraiser, inverse_of: :bundle_definitions

  has_many :bundle_definition_game_entries, inverse_of: :bundle_definition, dependent: :destroy
  has_many :bundles, inverse_of: :bundle_definition, dependent: :nullify
  has_many :games, through: :bundle_definition_game_entries
  has_many :keys, through: :games

  accepts_nested_attributes_for :bundle_definition_game_entries, allow_destroy: true

  after_commit :update_assignments, on: [:update]

  aasm do
    state :draft, initial: true
    state :live

    event :publish do
      transitions from: :draft, to: :live
    end

    event :retract do
      transitions from: :live, to: :draft
    end
  end

  class << self
    def without_assignments
      previous = @without_assignments
      @without_assignments = true
      yield
      @without_assignments = previous
    end

    def without_assignments?
      !!@without_assignments
    end
  end

  def update_assignments(force: false)
    return if self.class.without_assignments? || (draft? && !force)

    bundles.each do |bundle|
      BundleKeyAssignmentJob.perform_later(bundle.id)
    end
  end
end
