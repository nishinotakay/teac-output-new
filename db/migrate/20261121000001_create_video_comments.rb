class CreateVideoComments < ActiveRecord::Migration[6.1]
  def change
    create_table :video_comments do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :post, null: false, foreign_key: true
      t.references :parent, foreign_key: { to_table: :video_comments }
      t.references :user, foreign_key: true
      t.references :admin, foreign_key: true
      t.text :content, null: false

      t.timestamps
    end

    add_index :video_comments, %i[post_id parent_id created_at]
  end
end
