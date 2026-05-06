# 動画コメントモデル: ユーザーが動画投稿に対して投稿するコメントを管理する

class PostComment < ApplicationRecord
  belongs_to :user
  belongs_to :post

  validates :content, presence: true
end
