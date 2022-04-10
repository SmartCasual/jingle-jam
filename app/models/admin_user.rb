# ## Schema Information
#
# Table name: `admin_users`
#
# ### Columns
#
# Name                          | Type               | Attributes
# ----------------------------- | ------------------ | ---------------------------
# **`id`**                      | `bigint`           | `not null, primary key`
# **`data_entry`**              | `boolean`          | `default(FALSE), not null`
# **`email`**                   | `string`           | `default(""), not null`
# **`encrypted_password`**      | `string`           | `default(""), not null`
# **`full_access`**             | `boolean`          | `default(FALSE), not null`
# **`last_otp_at`**             | `datetime`         |
# **`manages_users`**           | `boolean`          | `default(FALSE), not null`
# **`name`**                    | `string`           |
# **`otp_secret`**              | `string`           |
# **`remember_created_at`**     | `datetime`         |
# **`reset_password_sent_at`**  | `datetime`         |
# **`reset_password_token`**    | `string`           |
# **`support`**                 | `boolean`          | `default(FALSE), not null`
# **`created_at`**              | `datetime`         | `not null`
# **`updated_at`**              | `datetime`         | `not null`
#
class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true

  def email_address
    email
  end

  def has_2sv?
    otp_secret.present?
  end

  def permissions
    if full_access?
      ["full access"]
    else
      [].tap do |perms|
        perms << "data entry" if data_entry?
        perms << "manages users" if manages_users?
        perms << "support" if support?
      end
    end
  end
end
