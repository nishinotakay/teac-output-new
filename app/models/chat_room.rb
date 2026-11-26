class ChatRoom < ApplicationRecord
  belongs_to :tenant
  has_many :chat_room_users
  has_many :chat_messages
  has_many :users, through: :chat_room_users

  scope :in_current_tenant, -> { Current.tenant ? where(tenant: Current.tenant) : all }
  default_scope { in_current_tenant }

  def self.find_or_create_between!(user, partner)
    transaction do
      User.where(id: [user.id, partner.id]).order(:id).lock.load
      between(user, partner) || create_with_members!(user, partner)
    end
  end

  def self.between(user, partner)
    joins(:chat_room_users)
      .where(chat_room_users: { user_id: [user.id, partner.id] })
      .group(:id)
      .having('COUNT(*) = 2')
      .first
  end

  def self.create_with_members!(user, partner)
    chat_room = create!(tenant: user.tenant)
    chat_room.chat_room_users.create!(user: user)
    chat_room.chat_room_users.create!(user: partner)
    chat_room
  end
  private_class_method :create_with_members!

  def partner_for(user)
    users.find { |member| member.id != user.id }
  end
end
