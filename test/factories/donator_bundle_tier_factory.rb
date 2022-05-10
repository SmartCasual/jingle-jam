FactoryBot.define do
  factory :donator_bundle_tier do
    donator_bundle
    bundle_tier

    trait :fulfilled do
      keys do
        bundle_tier.games.map do |game|
          build(:key, game:, donator_bundle_tier: @instance)
        end
      end
    end

    trait :unfulfilled

    trait :locked do
      unlocked { false }
    end

    trait :unlocked do
      unlocked { true }
    end
  end
end
