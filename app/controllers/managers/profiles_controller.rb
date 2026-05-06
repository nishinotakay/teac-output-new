# マネージャー向けプロフィールコントローラ: マネージャー自身のプロフィール表示アクションを提供する

module Managers
  class ProfilesController < Managers::Base
    before_action :authenticate_manager!
    
    # マネージャー自身のプロフィール詳細を表示する
    def managers_show
    end
  end
end
