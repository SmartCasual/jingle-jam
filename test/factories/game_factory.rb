FactoryBot.define do
  factory :game do
    sequence(:name) { |n| "Game #{n}" }

    trait :with_keys do
      keys { FactoryBot.build_list(:key, 1, game: @instance) }
    end
  end
end
