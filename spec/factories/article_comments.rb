FactoryBot.define do
  factory :article_comment do
    content { "MyText" }
    confirmed { false }
    user { nil }
    article { nil }
  end
end
