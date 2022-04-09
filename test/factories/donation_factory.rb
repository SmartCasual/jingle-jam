require_relative "../support/aasm_factories"

FactoryBot.define do
  factory :donation do
    donator
    amount { Money.new(25_000) }
    message { "Some standard message" }
    stripe_payment_intent_id { "stripe_payment_intent_id" }

    transient do
      charity_split { {} }
    end

    AASMFactories.init(self, Donation)

    after(:build) do |donation, evaluator|
      evaluator.charity_split.each do |charity, split_amount|
        donation.charity_splits.build(
          donation:,
          charity:,
          amount: split_amount,
        )
      end
    end
  end
end
