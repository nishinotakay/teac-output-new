module Users
  class UsersController < Users::Base
    before_action :authenticate_user! # 認証ユーザーのみアクセス ログインしていないユーザーを強制的にログインページへ飛ばす

    def show
      @user = User.find(params[:id]) # 該当idのユーザーレコードをとってくる様に設定
      @profile = current_user.profile
    end

    def followings
      @user = User.find(params[:user_id])
      @users = @user.followings.page(params[:page]).per(30)
    end

    def followers
      @user = User.find(params[:user_id])
      @users = @user.followers.page(params[:page]).per(30)
    end

  end
end
