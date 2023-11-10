class ChatRoomChannel < ApplicationCable::Channel
  def subscribed
    # この行を編集する
    stream_from "chat_room_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  # ==========ここから編集する==========
  def speak(data)
    ActionCable.server.broadcast 'chat_room_channel', {chat_message: data['chat_message']}
  end
  # ==========ここまで編集する==========
end
