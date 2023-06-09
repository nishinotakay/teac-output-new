FactoryBot.define do
  factory :article_comment do
    article_comment_content { "MyText" }
    article_confirmed { "" }
    user { nil }
    article { nil }
  end
end
