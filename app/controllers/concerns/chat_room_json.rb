# frozen_string_literal: true

module ChatRoomJson
  extend ActiveSupport::Concern

  private

  def chat_room_json(chat_room, last_message)
    {
      id:          chat_room.id.to_s,
      partner:     chat_partner_json(chat_room.partner_for(@current_user)),
      lastMessage: last_message && { content: last_message.content, createdAt: last_message.created_at.iso8601 },
      createdAt:   chat_room.created_at.iso8601
    }
  end

  def chat_partner_json(partner)
    { id: partner.id.to_s, name: partner.name }
  end
end
