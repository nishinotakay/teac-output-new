import consumer from "./consumer"

// この行を編集する
const appChatRoom = consumer.subscriptions.create("ChatRoomChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    const chatMessages = document.getElementById('chat-messages');
    chatMessages.insertAdjacentHTML('beforeend', data['render_chat_message'] || data['chat_message']);
  },

  // ==========ここから編集する==========
  // speak: function(chat_message) {
    //return this.perform('speak', { chat_message: chat_message });
  //}
  speak: function(chat_message, chat_room_id) {
    return this.perform('speak', { chat_message: chat_message, chat_room_id: chat_room_id });
  }
  // ==========ここまで編集する==========
});

// ==========ここから追加する==========
if(/chat_rooms/.test(location.pathname)) {
  $(document).on("keydown", ".chat-room-message-form-textarea", function(e) {
    if (e.keyCode === 13 && !e.shiftKey) { // Shiftキーが押されていないことを確認
      e.preventDefault(); // フォーム送信を阻止

      const messageText = e.target.value.trim();
      if (messageText === '') {
        // 空白でエンターが押された場合は改行を行う
        e.target.value = e.target.value + "\n";
      } else {
        // テキストが入力されている場合はメッセージを送信
        const chat_room_id = $(this).data('chat_room_id');
        appChatRoom.speak(messageText, chat_room_id);
        e.target.value = ''; // テキストエリアをクリア
        e.preventDefault(); // フォーム送信を阻止
      }
    }
  });
}
