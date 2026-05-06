# frozen_string_literal: true
# ユーザーコントローラの基底クラス: ユーザー認証を強制し、usersレイアウトを適用する

module Users
  class Base < ApplicationController
    before_action :authenticate_user!
    layout 'users'
  end
end
