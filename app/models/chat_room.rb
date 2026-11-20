class ChatRoom < ApplicationRecord
  belongs_to :tenant
  has_many :chat_room_users
  has_many :chat_messages
  has_many :users, through: :chat_room_users

  scope :in_current_tenant, -> { Current.tenant ? where(tenant: Current.tenant) : all }
  default_scope { in_current_tenant }
end
