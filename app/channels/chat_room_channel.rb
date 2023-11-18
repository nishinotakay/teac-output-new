class ChatRoomChannel < ApplicationCable::Channel
  
  def subscribed
    stream_from "chat_room_channel" # chatroomに遷移すると、サーバーのchannel購読を開始。ないと非同期処理されない。
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak(data)
    # ActionCable.server.broadcast 'chat_room_channel', {chat_message: data['chat_message']}
    ChatMessage.create!(
      content: data['chat_message'],
      user_id: current_user.id,
      chat_room_id: data['chat_room_id']
    )
  end
end
