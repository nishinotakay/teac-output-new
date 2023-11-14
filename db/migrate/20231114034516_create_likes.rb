class CreateLikes < ActiveRecord::Migration[6.1]
  def change
    create_table :likes do |t|
      t.bigint :user_id
      t.bigint :article_id

      t.timestamps
    end
  end
end
