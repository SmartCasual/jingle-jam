FactoryBot.define do
  factory :donator do
    sequence(:name) { |n| "Donator #{n}" }

    trait :with_email_address do
      sequence(:email_address) { |n| "test-#{n}@example.com" }
    end

    trait :confirmed do
      confirmed_at { 2.days.ago }
    end
  end
end
