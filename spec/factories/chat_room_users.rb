# frozen_string_literal: true

FactoryBot.define do
  factory :chat_room_user do
    chat_room
    user { association :user, tenant: chat_room.tenant }
  end
end
