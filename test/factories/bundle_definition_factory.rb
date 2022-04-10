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

    AASMFactories.init(self, BundleDefinition)
  end
end
