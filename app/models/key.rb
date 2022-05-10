# ## Schema Information
#
# Table name: `keys`
#
# ### Columns
#
# Name                          | Type               | Attributes
# ----------------------------- | ------------------ | ---------------------------
# **`id`**                      | `bigint`           | `not null, primary key`
# **`code_bidx`**               | `string`           |
# **`code_ciphertext`**         | `text`             |
# **`encrypted_kms_key`**       | `text`             |
# **`created_at`**              | `datetime`         | `not null`
# **`updated_at`**              | `datetime`         | `not null`
# **`donator_bundle_tier_id`**  | `bigint`           |
# **`fundraiser_id`**           | `bigint`           |
# **`game_id`**                 | `bigint`           | `not null`
#
class Key < ApplicationRecord
  has_kms_key

  lockbox_encrypts :code, key: :kms_key
  blind_index :code

  belongs_to :game, inverse_of: :keys
  belongs_to :donator_bundle_tier, inverse_of: :keys, optional: true
  belongs_to :fundraiser, inverse_of: :keys, optional: true

  validates :code, presence: true

  scope :unassigned, -> { where(donator_bundle_tier: nil) }
  scope :assigned, -> { where.not(donator_bundle_tier: nil) }

  after_commit on: :create do
    KeyAssignment::RequestProcessor.recheck_database
  end

  def assigned?
    donator_bundle_tier_id.present?
  end
end
