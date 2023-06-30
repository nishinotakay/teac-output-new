FactoryBot.define do
  factory :article_comment do
    content { "MyText" }
    confirmed { "" }
    user { nil }
    article { nil }
  end
end
