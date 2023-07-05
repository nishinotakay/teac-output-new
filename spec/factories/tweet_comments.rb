FactoryBot.define do
  factory :tweet_comment do
    comment_content { "MyString" }
    user { nil }
    tweet { nil }
  end
end
