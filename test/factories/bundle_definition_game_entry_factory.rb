FactoryBot.define do
  factory :bundle_definition_game_entry do
    bundle_definition
    association(:game, :with_keys)
    price { nil }
  end
end
