FactoryBot.define do
  factory :tweet_comment do
    content { "tweet_comment_test" }
    association :user
    association :tweet
    recipient_id { tweet.user_id }
  end
end
