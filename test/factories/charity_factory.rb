FactoryBot.define do
  factory :charity do
    sequence(:name) { |n| "Charity #{n}" }
  end
end
