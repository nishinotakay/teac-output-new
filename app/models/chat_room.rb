class ChatRoom < ApplicationRecord
  has_many :chat_room_users
  # ここに追加
  has_many :chat_messages
  has_many :users, through: :chat_room_users
end
