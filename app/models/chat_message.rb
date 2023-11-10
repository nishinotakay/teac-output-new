class ChatMessage < ApplicationRecord
  belongs_to :user
  # この行を追加
  belongs_to :chat_room
end
