# テナントモデル: マネージャーが管理するスクール（テナント）の名称を管理する

class Tenant < ApplicationRecord
  validates :name, presence: true, length: { in: 1..20 }
end
