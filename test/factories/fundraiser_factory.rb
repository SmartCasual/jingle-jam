FactoryBot.define do
  factory :fundraiser do
    sequence(:name) { |n| "Fundraiser #{n}" }

    AASMFactories.init(self, Fundraiser)

    trait :with_live_bundle do
      bundles do
        build_list(:bundle, 1, :live)
      end
    end
  end
end
