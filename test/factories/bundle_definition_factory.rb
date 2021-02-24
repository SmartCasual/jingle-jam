FactoryBot.define do
  factory :bundle_definition do
    sequence(:name) { |n| "Bundle definition #{n}"}
  end
end
