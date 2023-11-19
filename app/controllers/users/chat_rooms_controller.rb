module Users
  class ChatRoomsController < Users::Base
    before_action :authenticate_user!

    def create
      current_user_chat_rooms = ChatRoomUser.where(user_id: current_user.id).map(&:chat_room)
      chat_room = ChatRoomUser.where(chat_room: current_user_chat_rooms, user_id: params[:user_id]).map(&:chat_room).first
      if chat_room.blank?
        chat_room = ChatRoom.create
        ChatRoomUser.create(chat_room: chat_room, user_id: current_user.id)
        ChatRoomUser.create(chat_room: chat_room, user_id: params[:user_id])
      else
        redirect_to action: :show, id: chat_room.id
      end
    end

    def show
      @chat_room = ChatRoom.find(params[:id])
      unless @chat_room.users.include?(current_user)
        redirect_to users_profiles_path, notice: "アクセス権限がありません"
      end
      # @chat_room_user は チャットの相手 @chat_room_partner が良いか悩む
      @chat_room_user = @chat_room.chat_room_users.where.not(user_id: current_user.id).first.user
      @chat_messages = ChatMessage.where(chat_room: @chat_room)
    end
  end
end
