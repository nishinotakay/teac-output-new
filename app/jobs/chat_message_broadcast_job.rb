class ChatMessageBroadcastJob < ApplicationJob
  queue_as :default

  def perform(chat_message)
    chat_room_user = find_chat_room_user(chat_message.chat_room, chat_message.user)
    ActionCable.server.broadcast 'chat_room_channel', { chat_message: render_chat_message(chat_message, chat_room_user) } # この処理で サーバーのchat_room_channel に chat_message がブロードキャストされ、相手側で高速表示される。
  end

  private

    def render_chat_message(chat_message, chat_room_user)
      ApplicationController.renderer.render(
        partial: 'users/chat_messages/chat_message',
        locals: {
          chat_message: chat_message,
          current_user: chat_message.user,
          chat_room_user: chat_room_user
        }
      )
    end

    def find_chat_room_user(chat_room, current_user)
      chat_room.chat_room_users.where.not(user_id: current_user.id).first.user
    end
end
