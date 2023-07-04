FactoryBot.define do
  factory :comment do
    comment_content { "MyString" }
    user { nil }
    tweet { nil }
  end
end
