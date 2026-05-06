# 記事フォルダ中間テーブルモデル: 記事とフォルダの多対多の関連付けを管理する

class ArticleFolder < ApplicationRecord
  belongs_to :article
  belongs_to :folder
end

