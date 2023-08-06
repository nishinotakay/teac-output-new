FactoryBot.define do
  factory :tweet_comment do
    sequence(:content) { |n| "tweet_comment_test#{n}" }
    association :user
    association :tweet
    recipient_id { tweet.user_id }
  end
end
