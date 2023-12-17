class ChatRoom < ApplicationRecord
  has_many :chat_room_users
  has_many :chat_messages
  has_many :users, through: :chat_room_users

  validate :users_count_within_limit, on: :create

  private

  def users_count_within_limit
    errors.add(:base, 'チャットルームは既に2人が登録済みです。') if users.count >= 2
  end
end
