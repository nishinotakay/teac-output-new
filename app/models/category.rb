class Category < ApplicationRecord
  belongs_to :course
  belongs_to :tenant

  scope :in_current_tenant, -> {
    Current.tenant ? where(tenant: Current.tenant) : all
  }

  default_scope { in_current_tenant }

  has_many :article_categories, dependent: :destroy
  has_many :articles, through: :article_categories

  before_validation :strip_name

  validates :name, presence: true, length: { maximum: 255 }

  private

  def strip_name
    self.name = name.strip if name
  end
end
