FactoryBot.define do
  factory :admin_user, aliases: [:admin] do
    sequence(:name) { |n| "Admin User #{n}" }
    sequence(:email_address) { |n| "test-admin-#{n}@example.com" }

    password { "password123" }
    password_confirmation { password }

    otp_secret { ROTP::Base32.random }

    trait :without_2sv do
      otp_secret { nil }
    end
  end
end
