FactoryBot.define do
  factory :key do
    code { SecureRandom.uuid }
    game
    donator_bundle_tier { nil }

    trait :unassigned

    trait :assigned do
      donator_bundle_tier
    end
  end
end
