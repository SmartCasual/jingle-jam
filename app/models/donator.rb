require "hmac"

# ## Schema Information
#
# Table name: `donators`
#
# ### Columns
#
# Name                      | Type               | Attributes
# ------------------------- | ------------------ | ---------------------------
# **`id`**                  | `bigint`           | `not null, primary key`
# **`chosen_name`**         | `string`           |
# **`email_address`**       | `string`           |
# **`name`**                | `string`           |
# **`created_at`**          | `datetime`         | `not null`
# **`updated_at`**          | `datetime`         | `not null`
# **`stripe_customer_id`**  | `string`           |
#
class Donator < ApplicationRecord
  has_many :donations, inverse_of: :donator, dependent: :nullify
  has_many :gifted_donations, inverse_of: :donated_by, dependent: :nullify, class_name: "Donation",
                              foreign_key: "donated_by_id"
  has_many :bundles, inverse_of: :donator, dependent: :nullify
  has_many :bundle_definitions, through: :bundles
  has_many :keys, through: :bundles

  has_many :curated_streamer_administrators, dependent: :destroy, inverse_of: :donator
  has_many :curated_streamers, through: :curated_streamer_administrators

  def assign_keys
    BundleDefinition.live.find_each do |bundle_definition|
      bundle = bundles.find_or_create_by!(bundle_definition:)
      BundleKeyAssignmentJob.perform_later(bundle.id)
    end
  end

  def total_donations
    donations.map(&:amount).reduce(Money.new(0), :+)
  end

  def hmac
    @hmac ||= HMAC::Generator.new(context: "sessions").generate(id:)
  end

  def display_name(current_donator: nil)
    return I18n.t("common.abstract.you") if current_donator == self

    chosen_name || name || I18n.t("common.abstract.anonymous")
  end
end
