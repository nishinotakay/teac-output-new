class CreateChatGpts < ActiveRecord::Migration[6.1]
  def change
    create_table :chat_gpts, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", id: :bigint do |t|
      t.text :prompt
      t.text :content
      t.references :user, index: true, null: false, foreign_key: true
      t.string :mode

      t.timestamps
    end
  end
end
