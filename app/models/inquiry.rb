class Inquiry < ApplicationRecord
  belongs_to :user
  attribute :hidden, :boolean, default: false
end
