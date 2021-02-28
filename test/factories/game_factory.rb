FactoryBot.define do
  factory :game do
    sequence(:name) { |n| "Game #{n}" }

    keys { FactoryBot.build_list(:key, 1, game: @instance) }
  end
end
