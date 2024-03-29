class PublicAbility < ApplicationAbility
  def initialize(donator)
    super()

    allow_reading_public_info

    if donator.is_a?(Donator) && donator.persisted?
      allow_reading_own_stuff(donator)
      allow_editing_own_stuff(donator)
    end
  end

private

  def allow_reading_own_stuff(donator)
    can :read, Donation, donator_id: donator.id
    can :read, Donator, id: donator.id
    can :read, DonatorBundle, donator_id: donator.id
    can :read, DonatorBundleTier, donator_bundle: { donator_id: donator.id }
    can :read, Key, donator_bundle_tier: { donator_bundle: { donator_id: donator.id } }
  end

  def allow_editing_own_stuff(donator)
    can :edit, Donator, id: donator.id
  end
end
