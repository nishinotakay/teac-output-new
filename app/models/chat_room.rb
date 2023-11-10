class ChatRoom < ApplicationRecord
  # ==========ここから追加==========
  has_many :chat_room_users
  has_many :users, through: :chat_room_users
  # ==========ここまで追加==========
end
