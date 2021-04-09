class PublicAbility < ApplicationAbility
  def initialize(donator)
    super()

    allow_reading_public_info
    allow_reading_own_stuff(donator)
  end

private

  def allow_reading_own_stuff(donator)
    return unless donator.is_a?(Donator)

    can :read, Bundle, donator_id: donator.id
    can :read, Donation, donator_id: donator.id
    can :read, Donator, id: donator.id
    can :read, Key, bundle: { donator_id: donator.id }
  end
end
