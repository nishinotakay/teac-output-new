class Stock < ApplicationRecord
  belongs_to :user
  belongs_to :article

  validates :user_id, presence: true
  validates :article_id, presence: true

  def self.get_stock_article(user)
    self.where(user_id: user.id).map(&:article)
  end
end
