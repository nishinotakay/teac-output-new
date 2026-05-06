# ストックモデル: ユーザーが気に入った記事をブックマーク（ストック）する機能を管理する

class Stock < ApplicationRecord
  belongs_to :user
  belongs_to :article

  validates :user_id, presence: true
  validates :article_id, presence: true

end
