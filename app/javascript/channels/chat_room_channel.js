import consumer from "./consumer"

if(/chat_rooms/.test(location.pathname)) { // このif分岐内でappChatRoomを定義しないと、全てのページでWebSocket通信が実行されてしまう。linkに/chat_rooms/を含む場合、ということ。
  const appChatRoom = consumer.subscriptions.create("ChatRoomChannel", {
    connected() {
      // これはWebSocketの通信の状態を表すオブジェクト属性の一つ。サーバー上でサブスクリプションを使用する準備ができたら呼び出される。使用用途の詳細は Railsガイド7.1 みて。今後使えそう
    },
  
    disconnected() {
      // サブスクリプションがサーバーによって終了されたときに呼び出されます
    },
  
    received(data) {
      const chatMessages = document.getElementById('chat-messages');
      chatMessages.insertAdjacentHTML('beforeend', data['render_chat_message'] || data['chat_message']);
    },
  
    speak: function(chat_message, chat_room_id) { // ここでspeakというカスタム関数を定義
      return this.perform('speak', { chat_message: chat_message, chat_room_id: chat_room_id });
    } // 引数の'speak'アクションはapp/channels/chat_room_channel.rbへ
  });
  
  $(document).on("keydown", ".chat-room-message-form-textarea", function(e) {
    if (e.keyCode === 13 && !e.shiftKey) { // Shiftキーが押されていないことを確認
      e.preventDefault(); // デフォルトのフォーム送信を阻止する実装

      const messageText = e.target.value;
      if (messageText.match(/^\s*$/)) {
        // 空白でエンターが押された場合は改行を行う
        e.target.value += "\n";
      } else {
        // テキストが入力されている場合はメッセージを送信
        const chat_room_id = $(this).data('chat_room_id');
        appChatRoom.speak(messageText, chat_room_id);
        e.target.value = ''; // テキストエリアをクリア
      }
    }
  });
}
