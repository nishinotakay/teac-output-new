class Relationship < ApplicationRecord
  belongs_to :follower, class_name: 'User'
  belongs_to :followed, class_name: 'User'

  validate :not_already_following, on: :create
  validate :not_following_self
  validate :same_tenant

  private

  def not_already_following
    errors.add(:base, :already_following) if Relationship.exists?(follower_id: follower_id, followed_id: followed_id)
  end

  def not_following_self
    errors.add(:base, :following_self) if follower_id == followed_id
  end

  # API では他テナントの受講生は先に 404 になる。コンソール・rake など別の経路の守り
  def same_tenant
    return if follower.nil? || followed.nil?

    errors.add(:base, :different_tenant) if follower.tenant_id != followed.tenant_id
  end
end
