FactoryBot.define do
  factory :tweet do
    post { Faker::Lorem.characters(number: 100) }
    association :user

    trait :valid do
      post { "This is a test tweet" }
    end

    trait :invalid do
      post { Faker::Lorem.characters(number: 256) }
    end

    trait :nil_params do
      post { "" }
    end
  end
end
