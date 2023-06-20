class Profile < ApplicationRecord
  has_one_attached :image
  belongs_to :user

  validates :learning_start, presence: true
  validates :purpose, presence: true

  enum gender: { male: 0, female: 1, other: 2 }

  def self.sort_filter(order, filter)
    profiles = self.all
    # Apply filters
    filter.each do |ord, fit|
      # Check if it's a text field for fuzzy search
      if [:name, :purpose].include?(ord) && fit.present?
        profiles = profiles.where("lower(#{ord}) LIKE ?", "%#{fit.downcase}%")
      # For non-text fields use exact match
      elsif fit.present?
        profiles = profiles.where(ord => fit)
      end
    end
    # Apply sorting
    order.each do |ord, direction|
      profiles = profiles.order(ord => direction) if direction.present?
    end
    return profiles
  end

end

