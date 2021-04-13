FactoryBot.define do
  factory :admin_comment, class: "ActiveAdmin::Comment" do
    author factory: :admin_user
    body { "A comment body" }
    namespace { :admin }
    resource factory: :game
  end
end
