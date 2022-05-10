FactoryBot.define do
  factory :bundle_tier do
    bundle

    price { Money.new(5_00, "GBP") }

    transient do
      game { build(:game, :with_keys) }
    end

    bundle_tier_games do
      FactoryBot.build_list(:bundle_tier_game, 1, bundle_tier: @instance, game:)
    end

    trait :empty do
      bundle_tier_games { [] }
    end

    trait :without_keys do
      game { build(:game) }
    end
  end
end
