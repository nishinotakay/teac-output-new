class CreateArticleFolders < ActiveRecord::Migration[6.1]
  def change
    create_table :article_folders do |t|
      t.references :article, foreign_key: true
      t.references :folder, foreign_key: true
      t.references :admin, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
