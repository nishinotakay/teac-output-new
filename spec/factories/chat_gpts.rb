FactoryBot.define do
  factory :chat_gpt do
    prompt { "MyText" }
    content { "MyText" }
    user { nil }
    mode { "MyString" }
  end
end
