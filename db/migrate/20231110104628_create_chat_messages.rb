class CreateChatMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :chat_messages do |t|
      # ==========ここから追加する==========
      t.references :chat_room, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :content
      # ==========ここまで追加する==========
      t.timestamps
    end
  end
end
