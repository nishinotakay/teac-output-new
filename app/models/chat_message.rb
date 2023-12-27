class ChatMessage < ApplicationRecord
  belongs_to :user
  belongs_to :chat_room

  validates :content, presence: true

  after_create_commit { ChatMessageBroadcastJob.perform_later self } # チャットメッセ生成の後に実行する、この処理がサーバーへブロードキャストして双方向通信（継続通信）となり、リアルタイム（高速）表示が実現する。
end
