FactoryBot.define do
  factory :tweet do
    post { "it's sunny day!" }
    association :user
  end
end
