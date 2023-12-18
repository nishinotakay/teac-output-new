FactoryBot.define do
  factory :post_comment do
    content { "MyText" }
    confirmed { false }
    user { nil }
    post { nil }
  end
end
