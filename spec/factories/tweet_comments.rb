FactoryBot.define do
  factory :tweet_comment do
    content { "MyString" }
    user { nil }
    tweet { nil }
  end
end
