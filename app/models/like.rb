class Like < ApplicationRecord
  belongs_to :user
  belongs_to :article, optional: true
  belongs_to :post, optional: true
  belongs_to :tweet, optional: true

  validate :validate_either_article_or_post_or_tweet
  validates_uniqueness_of :article_id, scope: :user_id, allow_nil: true
  validates_uniqueness_of :post_id, scope: :user_id, allow_nil: true
  validates_uniqueness_of :tweet_id, scope: :user_id, allow_nil: true 

  private

  def validate_either_article_or_post_or_tweet
    unless article_id.present? ^ post_id.present? ^ tweet_id.present? # つぶやき用のバリデーションを追加
      errors.add(:base, "Article、Post、またはTweetのいずれかを選択してください")
    end
  end
end