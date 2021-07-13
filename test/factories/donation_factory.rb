FactoryBot.define do
  factory :donation do
    donator
    amount { Money.new(25_000) }
    message { "Some standard message" }

    transient do
      charity_split { {} }
    end

    after(:build) do |donation, evaluator|
      evaluator.charity_split.each do |charity, split_amount|
        donation.charity_splits.build(
          donation: donation,
          charity: charity,
          amount: split_amount,
        )
      end
    end
  end
end
