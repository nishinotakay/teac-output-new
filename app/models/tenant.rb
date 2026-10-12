class Tenant < ApplicationRecord
  has_many :users
  has_many :admins
  validates :name, presence: true, uniqueness: true, length: { in: 1..20 }

  def has_user?(user)
    user.tenant_id == self.id
  end

end
