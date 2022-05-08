require_relative "../support/aasm_factories"

FactoryBot.define do
  factory :bundle do
    sequence(:name) { |n| "Bundle #{n}" }

    fundraiser { Fundraiser.active.first || association(:fundraiser, :active) }

    transient do
      price { Money.new(25_00, "GBP") }
    end

    bundle_tiers do
      build_list(:bundle_tier, 1, bundle: @instance, price:)
    end

    trait :empty do
      bundle_tiers do
        build_list(:bundle_tier, 1, :empty, bundle: @instance, price:)
      end
    end

    trait :tiered do
      bundle_tiers do
        [
          build(:bundle_tier, bundle: @instance, price:),
          build(:bundle_tier, bundle: @instance, price: Money.new(15_00, "GBP")),
          build(:bundle_tier, bundle: @instance, price: Money.new(10_00, "GBP")),
        ]
      end
    end

    AASMFactories.init(self, Bundle)
  end
end
