class Like < ApplicationRecord
  belongs_to :user
  belongs_to :article, optional: true
  belongs_to :post, optional: true

  validate :validate_either_article_or_post
  validates_uniqueness_of :article_id, scope: :user_id, allow_nil: true
  validates_uniqueness_of :post_id, scope: :user_id, allow_nil: true

  private

  def validate_either_article_or_post
    unless article_id.present? ^ post_id.present?
      errors.add(:base, "ArticleまたはPostを選択してください")
    end
  end
end
