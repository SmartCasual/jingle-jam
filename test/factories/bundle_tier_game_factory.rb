FactoryBot.define do
  factory :bundle_tier_game do
    bundle_tier
    association(:game, :with_keys)
  end
end
