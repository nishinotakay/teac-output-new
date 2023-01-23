# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable,
    :confirmable

  has_many :articles, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_one :profile, dependent: :destroy
  has_many :tweets, dependent: :destroy
  has_many :inquiries, dependent: :destroy

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_REGEX }
  validates :name,  presence: true, length: { in: 1..10 }
  validates :age,   allow_nil: true, numericality: { greater_than_or_equal_to: 10 }
  validates :profile, length: { maximum: 200 } #追記

  enum gender: { male: 0, female: 1, other: 2 }
end
