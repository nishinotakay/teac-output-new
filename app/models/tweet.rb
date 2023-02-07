class Tweet < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy #この行を追加

  validates :post, presence: true, length: { maximum: 280 }
end
