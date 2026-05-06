# frozen_string_literal: true
# マネージャーモデル: テナント（スクール）を管理するスーパー管理者アカウントの認証を管理する

class Manager < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable,
    :confirmable
end
