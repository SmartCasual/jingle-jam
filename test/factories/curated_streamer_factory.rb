FactoryBot.define do
  factory :curated_streamer do
    sequence(:twitch_username) { |n| "streamer_#{n}" }
  end
end
