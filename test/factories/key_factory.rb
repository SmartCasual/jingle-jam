FactoryBot.define do
  factory :key do
    code { SecureRandom.uuid }
    game
    bundle { nil }
  end
end
