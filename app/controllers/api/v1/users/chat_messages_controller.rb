# frozen_string_literal: true

class Api::V1::Users::ChatMessagesController < Api::V1::BaseController
  include ChatRoomJson

  before_action :authenticate_user!
  before_action :set_chat_room

  # GET /api/v1/chat_rooms/:chat_room_id/messages
  def index
    chat_messages = @chat_room.chat_messages.order(:created_at, :id)
    chat_messages = chat_messages.where('chat_messages.id > ?', params[:after_id].to_i) if params[:after_id].present?

    render json: {
      chatRoom:     { id: @chat_room.id.to_s, partner: chat_partner_json(@chat_room.partner_for(@current_user)) },
      chatMessages: chat_messages.map { |chat_message| chat_message_json(chat_message) }
    }
  end

  # POST /api/v1/chat_rooms/:chat_room_id/messages
  def create
    chat_message = @chat_room.chat_messages.build(user: @current_user, content: params[:content])
    if chat_message.save
      render json: { chatMessage: chat_message_json(chat_message) }, status: :created
    else
      render json: { errors: chat_message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  # 参加していない部屋・他テナントの部屋は自分の部屋に含まれず 404 になる
  def set_chat_room
    @chat_room = @current_user.chat_rooms.preload(:users).find_by(id: params[:chat_room_id])
    render_not_found('チャット') unless @chat_room
  end

  def chat_message_json(chat_message)
    {
      id:        chat_message.id.to_s,
      userId:    chat_message.user_id.to_s,
      content:   chat_message.content,
      isMine:    chat_message.user_id == @current_user.id,
      createdAt: chat_message.created_at.iso8601
    }
  end
end
