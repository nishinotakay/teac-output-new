FactoryBot.define do
  factory :post do
    title { Faker::Lorem.characters(number: 30) }
    body { Faker::Lorem.characters(number: 240) }
    youtube_url { 'https://www.youtube.com/watch?v=v-Mb2voyTbc' }
    association :user
    association :admin
  end
end
