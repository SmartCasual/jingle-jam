FactoryBot.define do
  factory :admin_user, aliases: [:admin] do
    sequence(:email) { |n| "test-admin-#{n}@example.com" }

    password { "password" }
    password_confirmation { password }
  end
end
