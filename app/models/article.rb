# frozen_string_literal: true

class Article < ApplicationRecord
  mount_uploader :image, ImageUploader #ようせい追加（画像保存）

  belongs_to :user
  validates :title, presence: true, length: { in: 1..20 }
  validates :sub_title, allow_nil: true, length: { in: 1..40 }
  validates :content, presence: true
end
