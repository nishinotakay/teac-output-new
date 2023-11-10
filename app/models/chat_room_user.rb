class ChatRoomUser < ApplicationRecord
  # ==========ここから追加==========
  belongs_to :chat_room
  belongs_to :user
  # ==========ここまで追加==========
end
