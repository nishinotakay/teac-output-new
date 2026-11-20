class ChatRoomUser < ApplicationRecord
  belongs_to :chat_room
  belongs_to :user

  validates :user_id, uniqueness: { scope: :chat_room_id }
  validate :validate_users_count_within_limit, on: :create
  validate :same_tenant_as_chat_room

  private

  def validate_users_count_within_limit
    if chat_room.chat_room_users.count == 2
      errors.add(:base, 'チャットルームは既に2人が登録済みです。')
    end
  end

  def same_tenant_as_chat_room
    return if chat_room.nil? || user.nil?

    errors.add(:base, :different_tenant) if chat_room.tenant_id != user.tenant_id
  end
end
