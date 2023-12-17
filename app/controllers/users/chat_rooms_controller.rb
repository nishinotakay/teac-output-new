module Users
  class ChatRoomsController < Users::Base
    before_action :authenticate_user!

    def create
      partner_user_id = chat_room_params[:user_id].to_i
      if current_user.id == partner_user_id
        redirect_to(users_profiles_path, danger: 'アクセス権限がありません') and return
      end

      ActiveRecord::Base.transaction do
        current_user_chat_rooms = ChatRoomUser.includes(:chat_room).where(user_id: current_user.id).map(&:chat_room)
        chat_room = ChatRoomUser.includes(:chat_room).where(chat_room: current_user_chat_rooms,
          user_id: partner_user_id).map(&:chat_room).first

        if chat_room.blank?
          chat_room = ChatRoom.create!
          ChatRoomUser.create(chat_room: chat_room, user_id: current_user.id)
          ChatRoomUser.create(chat_room: chat_room, user_id: partner_user_id)
        end
        redirect_to action: :show, id: chat_room.id
      end
    rescue ActiveRecord::RecordInvalid
      flash[:danger] = '不正な操作があり失敗しました'
      redirect_to users_profiles_path
    end

    def show
      @chat_room = ChatRoom.find_by(id: params[:id])
      if @chat_room.nil? || !@chat_room.users.include?(current_user)
        redirect_to users_profiles_path, danger: 'アクセス権限がありません' and return
      end

      @chat_room_user = @chat_room.chat_room_users.where.not(user_id: current_user.id).first.user
      @chat_messages = ChatMessage.includes(:user).where(chat_room: @chat_room)
    end

    private

    def chat_room_params
      params.permit(:user_id)
    end
  end
end
