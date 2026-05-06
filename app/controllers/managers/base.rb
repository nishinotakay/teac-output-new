# frozen_string_literal: true
# マネージャーコントローラの基底クラス: マネージャー認証を強制し、managersレイアウトを適用する

module Managers
  class Base < ApplicationController
    before_action :authenticate_manager!
    layout 'managers'
  end
end
