FactoryBot.define do
  factory :donation do
    donator
    amount { Money.new(25000) }
  end
end
