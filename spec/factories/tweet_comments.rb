FactoryBot.define do
  factory :tweet_comment do
    content { 'MyString' }
    association :user
    association :tweet
    recipient_id { tweet.user_id }
  end
end
