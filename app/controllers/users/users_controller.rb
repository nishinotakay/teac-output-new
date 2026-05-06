# ユーザー向けユーザー情報コントローラ: ユーザー詳細表示・フォロー中/フォロワー一覧の取得を提供する

module Users
  class UsersController < Users::Base
    before_action :authenticate_user!

    # ユーザーの詳細情報と自分のプロフィールを表示する
    def show
      @user = User.find(params[:id])
      @profile = current_user.profile
    end

    # 指定ユーザーのフォロー中ユーザー一覧を表示する
    def followings
      @user = User.find(params[:user_id])
      @users = @user.followings.page(params[:page]).per(10)
    end

    # 指定ユーザーのフォロワー一覧を表示する
    def followers
      @user = User.find(params[:user_id])
      @users = @user.followers.page(params[:page]).per(10)
    end

  end
end
