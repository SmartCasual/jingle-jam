# ## Schema Information
#
# Table name: `donators`
#
# ### Columns
#
# Name                          | Type               | Attributes
# ----------------------------- | ------------------ | ---------------------------
# **`id`**                      | `bigint`           | `not null, primary key`
# **`chosen_name`**             | `string`           |
# **`confirmation_sent_at`**    | `datetime`         |
# **`confirmation_token`**      | `string`           |
# **`confirmed_at`**            | `datetime`         |
# **`email_address`**           | `string`           |
# **`encrypted_password`**      | `string`           |
# **`failed_attempts`**         | `integer`          | `default(0), not null`
# **`locked_at`**               | `datetime`         |
# **`name`**                    | `string`           |
# **`remember_created_at`**     | `datetime`         |
# **`reset_password_sent_at`**  | `datetime`         |
# **`reset_password_token`**    | `string`           |
# **`unconfirmed_email`**       | `string`           |
# **`unlock_token`**            | `string`           |
# **`created_at`**              | `datetime`         | `not null`
# **`updated_at`**              | `datetime`         | `not null`
# **`stripe_customer_id`**      | `string`           |
# **`twitch_id`**               | `string`           |
#
class Donator < ApplicationRecord
  ## Devise
  devise(
    :confirmable,
    :database_authenticatable,
    :lockable,
    :omniauthable,
    :recoverable,
    :registerable,
    :rememberable,
    :validatable,
    omniauth_providers: %i[
      token
      twitch
    ],
  )

  alias_attribute :email, :email_address
  alias_attribute :unconfirmed_email_address, :unconfirmed_email
  skip_uniqueness_validation :email
  validate :email_address, -> {
    if email_address.present? && self.class.confirmed.where.not(id:).exists?(email_address:)
      errors.add(:email_address, :taken)
    end
  }

  # If we have a password present then we need an email address,
  # since that's the username used to match with the password.
  def email_required?
    password.present? || encrypted_password.present?
  end

  # We never require a password even if the email address is set
  # because it can be set in a variety of ways that don't need
  # logging in via password.
  #
  # By default Devise will not log a user in via password if the
  # password is blank, so we're safe from an attacker guessing
  # blank passwords even if the email address is set.
  def password_required?
    false
  end

  # We allow donators with no email address, so it doesn't make sense
  # to require donators that *do* have an email address to have confirmed it.
  def active_for_authentication?
    true
  end

  scope :confirmed, -> { where.not(confirmed_at: nil) }
  ## /Devise

  has_many :donations, inverse_of: :donator, dependent: :nullify
  has_many :gifted_donations, inverse_of: :donated_by, dependent: :nullify, class_name: "Donation",
                              foreign_key: "donated_by_id"
  has_many :bundles, inverse_of: :donator, dependent: :nullify
  has_many :bundle_definitions, through: :bundles
  has_many :keys, through: :bundles

  has_many :curated_streamer_administrators, dependent: :destroy, inverse_of: :donator
  has_many :curated_streamers, through: :curated_streamer_administrators

  validates :twitch_id, uniqueness: true, allow_nil: true

  def self.create_from_omniauth!(auth_hash)
    case (provider = auth_hash["provider"])
    when "twitch"
      Donator.create!(
        chosen_name: auth_hash.dig("info", "nickname"),
        email_address: auth_hash.dig("info", "email"),
        name: auth_hash.dig("info", "name"),
        twitch_id: auth_hash["uid"],
      )
    else
      raise "Unsupported provider: #{provider}"
    end
  end

  def email_address=(new_email_address)
    super(new_email_address.presence)
    @token_with_email_address = nil
  end

  def assign_keys
    Fundraiser.active.open.find_each do |fundraiser|
      fundraiser.bundle_definitions.live.find_each do |bundle_definition|
        bundle = bundles.find_or_create_by!(bundle_definition:)
        BundleKeyAssignmentJob.perform_later(bundle.id)
      end
    end
  end

  def total_donations(fundraiser: nil)
    if fundraiser
      donations.where(fundraiser:)
    else
      donations
    end.map(&:amount).reduce(Money.new(0), :+)
  end

  def token
    @token ||= HMAC::Generator
      .new(context: "sessions")
      .generate(id:)
  end

  def token_with_email_address
    @token_with_email_address ||= HMAC::Generator
      .new(context: "sessions")
      .generate(id:, extra_fields: {
                  email_address:,
                },
      )
  end

  def display_name(current_donator: nil)
    return I18n.t("common.abstract.you") if current_donator == self

    chosen_name.presence || name.presence || I18n.t("common.abstract.anonymous")
  end

  def anonymous?
    name.blank? && chosen_name.blank?
  end

  def twitch_connected?
    twitch_id.present?
  end

  def no_identifying_marks?
    email_address.blank? && twitch_id.blank?
  end
end
