FactoryBot.define do
  factory :admin_user, aliases: [:admin] do
    sequence(:email) { |n| "test-admin-#{n}@example.com" }

    password { "password" }
    password_confirmation { password }

    otp_secret { ROTP::Base32.random }

    trait :without_2sv do
      otp_secret { nil }
    end
  end
end
