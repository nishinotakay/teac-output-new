class ChatRoomUser < ApplicationRecord
  belongs_to :chat_room
  belongs_to :user

  validates :user_id, uniqueness: { scope: :chat_room_id }
  validate :validate_users_count_within_limit, on: :create

  private

  def validate_users_count_within_limit
    if chat_room.chat_room_users.size >= 2
      errors.add(:base, 'チャットルームは最大2人までです。')
    end
  end
end
