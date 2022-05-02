FactoryBot.define do
  factory :fundraiser do
    sequence(:name) { |n| "Fundraiser #{n}" }

    AASMFactories.init(self, Fundraiser)
  end
end
