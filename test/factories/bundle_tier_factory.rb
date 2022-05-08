FactoryBot.define do
  factory :bundle_tier do
    bundle

    price { Money.new(5_00, "GBP") }

    bundle_tier_games do
      FactoryBot.build_list(:bundle_tier_game, 1, bundle_tier: @instance, game: build(:game, :with_keys))
    end

    trait :empty do
      bundle_tier_games { [] }
    end
  end
end
