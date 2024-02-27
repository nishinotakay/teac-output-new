class Category < ApplicationRecord
  has_many :aritcles_categories
  has_many :articles, through: :aritcles_categories
end
