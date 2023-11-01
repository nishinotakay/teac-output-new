FactoryBot.define do
  factory :post do
    title { Faker::Lorem.characters(number: 30) }
    body { Faker::Lorem.characters(number: 240) }
    youtube_url { Faker::Lorem.characters(number: 40) }
    association :user
    association :admin
  end
end
