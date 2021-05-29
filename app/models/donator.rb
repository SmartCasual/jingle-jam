require "hmac"

# ## Schema Information
#
# Table name: `donators`
#
# ### Columns
#
# Name                 | Type               | Attributes
# -------------------- | ------------------ | ---------------------------
# **`id`**             | `bigint`           | `not null, primary key`
# **`chosen_name`**    | `string`           |
# **`email_address`**  | `string`           |
# **`name`**           | `string`           |
# **`created_at`**     | `datetime`         | `not null`
# **`updated_at`**     | `datetime`         | `not null`
#
class Donator < ApplicationRecord
  has_many :donations, inverse_of: :donator, dependent: :nullify
  has_many :bundles, inverse_of: :donator, dependent: :nullify
  has_many :bundle_definitions, through: :bundles
  has_many :keys, through: :bundles

  def assign_keys
    BundleDefinition.find_each do |bundle_definition|
      bundle = bundles.find_or_create_by!(bundle_definition: bundle_definition)
      BundleKeyAssignmentJob.perform_later(bundle.id)
    end
  end

  def total_donations
    donations.map(&:amount).reduce(Money.new(0), :+)
  end

  def hmac
    @hmac ||= HMAC::Generator.new(context: "sessions").generate(id: id)
  end

  def display_name
    chosen_name || name || "Anonymous"
  end
end
