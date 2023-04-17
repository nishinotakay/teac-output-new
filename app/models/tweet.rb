class Tweet < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy # この行を追加
  has_many_attached :images

  validates :post, presence: true, length: { maximum: 280 }
  validate :image_count_validation, :image_size_varidation, :image_type_validation

  private

  def image_count_validation
    if images.count > 4
      errors.add(:images, 'は4つまでしかアップロードできません。')
    end
  end

  def image_size_varidation
    images.each do |image|
      if image.blob.byte_size > 5.megabytes
        errors.add(:images, 'は1つのファイル5MB以内にして下さい。')
      end
    end
  end

  def image_type_validation
    allowed_types = ['image/png', 'image/jpeg'] # 保存可能なファイル形式を配列で代入
    images.each do |image|
      unless allowed_types.include?(image.blob.content_type) # include?メソッドはArrayクラスに定義さてているメソッド
        errors.add(:images, 'はpng形式またはjpeg形式でアップロードして下さい。')
      end
    end
  end
end
