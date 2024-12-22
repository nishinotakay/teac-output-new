class Tenant < ApplicationRecord
  has_many :users
  validates :name, presence: true, length: { in: 1..20 }

  def has_user?(user)
    user.tenant_id == self.id
  end

end
