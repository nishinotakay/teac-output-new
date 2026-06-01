class Like < ApplicationRecord
  belongs_to :user
  belongs_to :article, optional: true
  belongs_to :post, optional: true
  belongs_to :tweet, optional: true

  validate :validate_exactly_one_target
  validates_uniqueness_of :article_id, scope: :user_id, allow_nil: true
  validates_uniqueness_of :post_id, scope: :user_id, allow_nil: true
  validates_uniqueness_of :tweet_id, scope: :user_id, allow_nil: true

  private

  def validate_exactly_one_target
    present_count = [article_id, post_id, tweet_id].count(&:present?)
    unless present_count == 1
      errors.add(:base, "Article、Post、Tweetのいずれか1つを選択してください")
    end
  end
end
