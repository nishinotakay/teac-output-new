# frozen_string_literal: true
# 管理者（講師）コントローラの基底クラス: 管理者認証を強制し、adminsレイアウトを適用する

module Admins
  class Base < ApplicationController
    before_action :authenticate_admin!
    layout 'admins'
  end
end
