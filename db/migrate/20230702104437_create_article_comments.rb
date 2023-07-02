class CreateArticleComments < ActiveRecord::Migration[6.1]
  def change
    create_table :article_comments do |t|
      t.text :content
      t.boolean :confirmed, default: false
      t.references :user, null: false, foreign_key: true
      t.references :article, null: false, foreign_key: true

      t.timestamps
    end
  end
end
