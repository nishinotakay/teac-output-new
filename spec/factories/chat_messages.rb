# frozen_string_literal: true

FactoryBot.define do
  factory :chat_message do
    chat_room
    user { association :user, tenant: chat_room.tenant }
    content { 'こんにちは' }
  end
end
