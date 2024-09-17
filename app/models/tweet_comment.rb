class TweetComment < ApplicationRecord
  belongs_to :user # Coment.userでコメントの所有者を取得
  belongs_to :tweet # Comment.tweetでコメントがされたつぶやき投稿を取得

  validates :content, presence: true
end
