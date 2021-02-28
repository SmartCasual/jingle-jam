FactoryBot.define do
  factory :bundle_definition_game_entry do
    bundle_definition
    game
    price { nil }
  end
end
