class AdminAbility < ApplicationAbility
  def initialize(admin_user)
    super()

    return unless admin_user.is_a?(AdminUser)

    allow_reading_public_info
    allow_reading_self(admin_user)

    allow_managing_public_info if admin_user.data_entry?
    allow_reading_donation_info if admin_user.support?
    allow_managing_admin_accounts if admin_user.manages_users?

    can :manage, :all if admin_user.full_access?

    merge(AdminCommentAbility.new(admin_user))
  end

private

  def allow_reading_self(admin_user)
    can :read, AdminUser, id: admin_user.id
    can :read, ActiveAdmin::Page, name: "Dashboard", namespace_name: "admin"
  end

  def allow_managing_public_info
    public_classes.each { |klass| can(:manage, klass) }
  end

  def allow_reading_donation_info
    can :read, DonatorBundle
    can :read, Donation
    can :read, Donator
    can :read, ActiveAdmin::Page, name: "Donation accounting", namespace_name: "admin"
  end

  def allow_managing_admin_accounts
    can :manage, AdminUser
  end
end
