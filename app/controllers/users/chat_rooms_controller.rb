module Users
  class ChatRoomsController < Users::Base
    before_action :authenticate_user!

    def create
      if current_user.id == params[:user_id].to_i
        redirect_to(users_index_path, alert: '不正な操作です。') and return
      end

      current_user_chat_rooms = ChatRoomUser.includes(:chat_room).where(user_id: current_user.id).map(&:chat_room)
      chat_room = ChatRoomUser.includes(:chat_room).where(chat_room: current_user_chat_rooms, user_id: params[:user_id]).map(&:chat_room).first
      if chat_room.blank?
        chat_room = ChatRoom.create
        ChatRoomUser.create(chat_room: chat_room, user_id: current_user.id)
        ChatRoomUser.create(chat_room: chat_room, user_id: params[:user_id])
      end
      redirect_to action: :show, id: chat_room.id
    end

    def show
      @chat_room = ChatRoom.find(params[:id])
      unless @chat_room.users.include?(current_user)
        redirect_to users_profiles_path, notice: "アクセス権限がありません"
      end
      # @chat_room_user は チャットの相手 @chat_room_partner が良いか悩む
      @chat_room_user = @chat_room.chat_room_users.where.not(user_id: current_user.id).first.user
      @chat_messages = ChatMessage.includes(:user).where(chat_room: @chat_room)
    end
  end
end
