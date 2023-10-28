class Tweet < ApplicationRecord
  belongs_to :user
  has_many :tweet_comments, dependent: :destroy # この行を追加
  has_many_attached :images

  validates :post, presence: true, length: { maximum: 255 }
  validate :image_count_validation, :image_size_varidation, :image_type_validation

  def self.build_filter(params) # 渡されたパラメータからフィルタを構築
    {
      author: params[:author],
      post:   params[:post],
      start:  params[:start],
      finish: params[:finish],
      order:  params[:order] || 'DESC'
    }
  end

  def self.apply_and_sort_query(filter, user_id = nil, page = 1)
    start = Time.zone.parse(filter[:start].presence || '2022-01-01').beginning_of_day
    finish = Time.zone.parse(filter[:finish].presence || Date.current.to_s).end_of_day

    query = with_attached_images
            .includes(:user, { user: [:profile, { profile: :image_attachment }] }, :tweet_comments)
            .page(page) # ここでページ番号を指定
            .per(30)

    query = user_id ? query.where(user_id: user_id) : query

    query = filter.compact.blank? ? query : query.left_joins(:user)
                                                   .where('tweets.post LIKE :post', post: "%#{filter[:post]}%")
                                                   .where('tweets.created_at BETWEEN ? AND ?', start, finish)
                                                   .where('users.name LIKE :author', author: "%#{filter[:author]}%")

    query.order("tweets.created_at #{filter[:order]}" || 'DESC' ).presence || Tweet.none
  end

  def self.tweet_and_image(tweets)
    tweets.map do |tweet|
      {
        tweet: tweet,
        image: tweet.user.profile&.image&.attached? ? tweet.user.profile.image : 'user_default.png'
      }
    end
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
