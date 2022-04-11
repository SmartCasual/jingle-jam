require_relative "../support/aasm_factories"

FactoryBot.define do
  factory :bundle_definition do
    sequence(:name) { |n| "Bundle definition #{n}" }

    # £10
    price { Money.new(1000, "GBP") }

    bundle_definition_game_entries do
      FactoryBot.build_list(:bundle_definition_game_entry, 1, bundle_definition: @instance)
    end

    trait :empty do
      bundle_definition_game_entries { [] }
    end

    trait :tiered do
      bundle_definition_game_entries do
        [
          FactoryBot.build(:bundle_definition_game_entry, bundle_definition: @instance, price: Money.new(1000, "GBP")),
          FactoryBot.build(:bundle_definition_game_entry, bundle_definition: @instance),
        ]
      end

      price { Money.new(2000, "GBP") }
    end

    AASMFactories.init(self, BundleDefinition)
  end
end
