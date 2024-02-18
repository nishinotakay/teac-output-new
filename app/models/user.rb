# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable,
    :confirmable,
    :omniauthable, omniauth_providers: %i[google_oauth2 line facebook]

  has_many :articles, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_one :profile, dependent: :destroy
  has_many :tweets, dependent: :destroy
  has_many :inquiries, dependent: :destroy
  has_many :tweet_comments, dependent: :destroy
  has_many :article_comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :chat_room_users
  has_many :chat_rooms, through: :chat_room_users
  has_many :chat_messages
  has_many :post_comments, dependent: :destroy
  has_many :stocks, dependent: :destroy
  has_many :learning_status, class_name: "Learning", foreign_key: "learner_id", dependent: :destroy #学習している関連付け

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_REGEX }
  validates :name,  presence: true, length: { in: 1..10 }
  validates :age,   allow_nil: true, numericality: { greater_than_or_equal_to: 10 }
  validates :profile, length: { maximum: 200 } # 追記
  validates :uid, uniqueness: { scope: :provider }, allow_nil: true

  enum gender: { male: 0, female: 1, other: 2 }

  def self.sort_filter(order, filter)
    artcl_min = filter[:articles_min].blank? ? 0 : filter[:articles_min]
    artcl_max = filter[:articles_max].blank? ? Article.count : filter[:articles_max]
    posts_min = filter[:posts_min].blank? ? 0 : filter[:posts_min]
    posts_max = filter[:posts_max].blank? ? Post.count : filter[:posts_max]

    users = where(["name like ? and email like ?", "%#{filter[:name]}%", "%#{filter[:email]}%"])
      .left_joins(:articles).left_joins(:posts).group("users.id")
      .having("count(articles.id) between ? and ?", artcl_min, artcl_max)
      .having("count(posts.id) between ? and ?", posts_min, posts_max)
    if order[0] == :articles || order[0] == :posts || order[0] == :profiles
      users.order("COUNT(#{order[0].to_s}.id) #{order[1]}")
    else
      users.order(order[0] => order[1])
    end
  end

  def social_profile(provider)
    social_profiles.select { |sp| sp.provider == provider.to_s }.first
  end

  def set_values(omniauth)
    return if provider.to_s != omniauth["provider"].to_s || uid != omniauth["uid"]
    credentials = omniauth["credentials"]
    info = omniauth["info"]

    access_token = credentials["refresh_token"]
    access_secret = credentials["secret"]
    credentials = credentials.to_json
    name = info["name"]
    # self.set_values_by_raw_info(omniauth['extra']['raw_info'])
  end

  def set_values_by_raw_info(raw_info)
    self.raw_info = raw_info.to_json
    self.save!
  end

  def article_already_liked?(article_id)
    likes.where(article_id: article_id).exists?
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.name = auth.info.name
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.confirmed_at = Time.now
    end
  end

  def post_already_liked?(post_id)
    likes.where(post_id: post_id).exists?
  end

  def stock?(article)
    stocks.exists?(article_id: article.id)
  end

  def completed?(article)
    learning_status.exists?(learned_article_id: article.id, completed: true)
  end
end
