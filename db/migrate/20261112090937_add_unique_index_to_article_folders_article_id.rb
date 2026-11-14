class AddUniqueIndexToArticleFoldersArticleId < ActiveRecord::Migration[6.1]
  def change
    # 外部キーが article_id の index を使うため、ユニーク index を先に足してから旧 index を外す
    add_index :article_folders, :article_id, unique: true, name: 'index_article_folders_on_article_id_unique'
    remove_index :article_folders, column: :article_id, name: 'index_article_folders_on_article_id'
  end
end
