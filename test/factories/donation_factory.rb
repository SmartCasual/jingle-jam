FactoryBot.define do
  factory :donation do
    donator
    amount { Money.new(25_000) }
    message { "Some standard message" }
  end
end
