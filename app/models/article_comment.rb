# 記事コメントモデル: ユーザーが記事に投稿するコメントを管理する

class ArticleComment < ApplicationRecord
  belongs_to :user
  belongs_to :article

  validates :content, presence: true
end
