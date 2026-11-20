# frozen_string_literal: true

class Api::V1::Users::ChatRoomsController < Api::V1::BaseController
  include ChatRoomJson

  before_action :authenticate_user!

  # GET /api/v1/chat_rooms
  def index
    chat_rooms = @current_user.chat_rooms.preload(:users).to_a
    last_messages = latest_messages_by_chat_room_id(chat_rooms.map(&:id))
    sorted_chat_rooms = chat_rooms.sort_by do |chat_room|
      last_activity_at = last_messages[chat_room.id]&.created_at || chat_room.created_at
      [-last_activity_at.to_f, -chat_room.id]
    end

    render json: { chatRooms: sorted_chat_rooms.map { |chat_room| chat_room_json(chat_room, last_messages[chat_room.id]) } }
  end

  # POST /api/v1/chat_rooms
  def create
    partner = User.not_cancelled.find_by(id: params[:user_id])
    return render_not_found('受講生') unless partner
    return render json: { errors: ['自分自身とはチャットできません'] }, status: :unprocessable_entity if partner.id == @current_user.id
    # フォローしていない相手にも 404 を返し、相手の存在を区別させない
    return render_not_found('受講生') unless @current_user.followings.not_cancelled.exists?(partner.id)

    chat_room = ChatRoom.find_or_create_between!(@current_user, partner)
    status = chat_room.previously_new_record? ? :created : :ok
    render json: { chatRoom: chat_room_json(chat_room, chat_room.chat_messages.order(:created_at, :id).last) }, status: status
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  private

  def latest_messages_by_chat_room_id(chat_room_ids)
    latest_message_ids = ChatMessage.where(chat_room_id: chat_room_ids).group(:chat_room_id).maximum(:id).values
    ChatMessage.where(id: latest_message_ids).index_by(&:chat_room_id)
  end
end
