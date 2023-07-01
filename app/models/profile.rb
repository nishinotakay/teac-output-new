class Profile < ApplicationRecord
  has_one_attached :image
  belongs_to :user
  accepts_nested_attributes_for :user
  validates :learning_start, presence: true
  validates :purpose, presence: true

  enum gender: { male: 0, female: 1, other: 2 }

  def self.sort_filter(order, filter)
    profiles = self.joins(:user)
    filter.each do |ord, fit|
      if ord == :name && fit.present?
        profiles = profiles.where("lower(users.name) LIKE ?", "%#{fit.downcase}%")
      elsif ord == :purpose && fit.present?
        profiles = profiles.where("lower(profiles.purpose) LIKE ?", "%#{fit.downcase}%")
      elsif fit.present?
        profiles = profiles.where(ord => fit)
      end
    end
    order.each do |ord, direction|
      profiles = profiles.order(ord => direction) if direction.present?
    end
    if order[:name]
      profiles = profiles.order("users.name #{order[:name]}")
    end
    return profiles
  end
end

