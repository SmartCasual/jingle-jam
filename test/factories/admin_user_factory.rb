FactoryBot.define do
  factory :admin_user do
    sequence(:email) { |n| "test-admin-#{n}@example.com" }

    password { "password" }
    password_confirmation { password }
  end
end
