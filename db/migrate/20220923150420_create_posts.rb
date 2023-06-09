class CreatePosts < ActiveRecord::Migration[6.1]
  def change
    create_table :posts do |t|
      t.string :title
      t.text :body
      t.string :youtube_url
      t.references :user, null: false, foreign_key: true
      t.integer :admin_id
      t.timestamps
    end
  
    add_index :posts, :admin_id, name: "index_posts_on_admin_id"
  end
end
