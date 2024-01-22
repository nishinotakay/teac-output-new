class AddArticleInfoToArticles < ActiveRecord::Migration[6.1]
  def change
    add_column :articles, :article_type, :string
  end
end
