class Course < ApplicationRecord
  belongs_to :tenant

  scope :in_current_tenant, -> { Current.tenant ? where(tenant: Current.tenant) : all }
  default_scope { in_current_tenant }

  validates :name, presence: true, length: { maximum: 255 }
end
