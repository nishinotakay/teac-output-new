class ChatMessage < ApplicationRecord
  belongs_to :user
  belongs_to :chat_room

  after_create_commit { ChatMessageBroadcastJob.perform_later self } # チャットメッセ生成の後に実行する、この処理がサーバーへブロードキャストして非同期通信となり、高速表示が実現する。
end
