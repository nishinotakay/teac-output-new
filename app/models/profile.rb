class Profile < ApplicationRecord
  has_one_attached :image
  belongs_to :user
  accepts_nested_attributes_for :user
  
  validates :registration_date, presence: true
  validates :hobby, presence: true


  enum gender: { male: 0, female: 1, other: 2 }

  def self.get_sort_and_filter_params(params)
    order = {
      name: params[:ord_name],
      hobby: params[:ord_hobby],
      registration_date: params[:ord_registration_date]
    }.compact
  
    filter = {
      name: params[:flt_name],
      hobby: params[:flt_hobby],
      registration_date: params[:flt_registration_date]
    }.compact
  
    sort_and_filter_params = {order: order, filter: filter}
    return sort_and_filter_params
  end

  def self.sort_filter(order, filter)
    profiles = self.joins(:user)
    filter.each do |ord, fit|
      if ord == :name && fit.present?
        profiles = profiles.where("lower(users.name) LIKE ?", "%#{fit.downcase}%")
      elsif ord == :hobby && fit.present?
        profiles = profiles.where("lower(profiles.hobby) LIKE ?", "%#{fit.downcase}%")
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
