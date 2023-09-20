class Tweet < ApplicationRecord
  belongs_to :user
  has_many :tweet_comments, dependent: :destroy # この行を追加
  has_many_attached :images
  has_one :profile, through: :user

  validates :post, presence: true, length: { maximum: 255 }
  validate :image_count_validation, :image_size_varidation, :image_type_validation

  def self.sort_filter(filter)
    start = Time.zone.parse(filter[:start].presence || '2022-01-01').beginning_of_day
    finish = Time.zone.parse(filter[:finish].presence || Date.current.to_s).end_of_day

    left_joins(:user)
      .where('tweets.post LIKE :post', post: "%#{filter[:post]}%")
      .where('tweets.created_at BETWEEN ? AND ?', start, finish)
      .where('users.name LIKE :author', author: "%#{filter[:author]}%")
      .order("tweets.created_at #{filter[:order]}")
      .presence || Tweet.none
  end

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
    allowed_types = ['image/png', 'image/jpeg', 'image/jpg'] # 保存可能なファイル形式を配列で代入
    images.each do |image|
      unless allowed_types.include?(image.blob.content_type) # include?メソッドはArrayクラスに定義さてているメソッド
        errors.add(:images, 'はpng形式またはjpeg形式でアップロードして下さい。')
      end
    end
  end
end
