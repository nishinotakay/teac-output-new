# frozen_string_literal: true

class Admin < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable,
    :confirmable

  has_many :articles, dependent: :destroy
  has_many :posts, dependent: :destroy

  enum gender: { male: 0, female: 1, other: 2 }

  def self.sort_filter(order, filter)
    artcl_min = filter[:articles_min].blank? ? 0 : filter[:articles_min]
    artcl_max = filter[:articles_max].blank? ? Article.count : filter[:articles_max]
    posts_min = filter[:posts_min].blank? ? 0 : filter[:posts_min]
    posts_max = filter[:posts_max].blank? ? Post.count : filter[:posts_max]
    admins = where(['name like ? and email like ?', "%#{filter[:name]}%", "%#{filter[:email]}%"])
      .left_joins(:articles).left_joins(:posts).group('admins.id')
      .having('count(articles.id) between ? and ?', artcl_min, artcl_max)
      .having('count(posts.id) between ? and ?', posts_min, posts_max)
    if order[0] == :articles || order[0] == :posts
      admins.order("COUNT(#{order[0]}.id) #{order[1]}")
    else
      admins.order(order[0] => order[1])
    end
  end
end
