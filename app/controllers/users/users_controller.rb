module Users
  class UsersController < Users::Base
    before_action :authenticate_user! # 認証ユーザーのみアクセス ログインしていないユーザーを強制的にログインページへ飛ばす

    def index
    end

    def show
      @user = User.find(params[:id]) # 該当idのユーザーレコードをとってくる様に設定
      @profile = current_user.profile
    end
  end
end
