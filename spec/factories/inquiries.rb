FactoryBot.define do
  factory :inquiry do
    user { association(:user) }
    subject { Faker::Lorem.characters(number: 30) }
    content { Faker::Lorem.characters(number: 800) }
    sequence(:created_at) { |n| Time.now - n.days }

    trait :first_inquiry do
      subject { 'A' }
      content { 'A' }
      created_at { '2023-01-01 10:00:00' }
    end
    trait :second_inquiry do
      subject { 'B' }
      content { 'B' }
      created_at { '2023-01-02 11:00:00' }
    end
    trait :third_inquiry do
      subject { 'C' }
      content { 'C' }
      created_at { '2023-01-03 12:00:00' }
    end

    trait :visible do
      hidden { false }
    end

    trait :hidden do
      hidden { true }
    end

    trait :both do
      hidden { [true, false].sample }
    end
  end
end

