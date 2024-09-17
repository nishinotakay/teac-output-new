class CreateTweets < ActiveRecord::Migration[6.1]
  def change
    create_table :tweets do |t|
      t.string :post
      t.string :coment
      t.string :good
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
