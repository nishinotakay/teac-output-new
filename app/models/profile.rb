class Profile < ApplicationRecord
  has_one_attached :image
  belongs_to :user
  accepts_nested_attributes_for :user
  
  validates :registration_date, presence: true
  validates :hobby, presence: true

  enum gender: { male: 0, female: 1, other: 2 }
end
