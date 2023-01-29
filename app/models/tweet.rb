class Tweet < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy #この行を追加
end
