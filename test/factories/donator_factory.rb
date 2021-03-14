FactoryBot.define do
  factory :donator do
    trait :with_email_address do
      sequence(:email_address) { |n| "test-#{n}@example.com" }
    end
  end
end
