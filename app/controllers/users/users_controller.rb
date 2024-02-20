module Users
  class UsersController < Users::Base
    before_action :authenticate_user!

    def show
      @user = User.find(params[:id])
      @profile = current_user.profile
    end

    def followings
      @user = User.find(params[:user_id])
      @users = @user.followings.page(params[:page]).per(10)
    end

    def followers
      @user = User.find(params[:user_id])
      @users = @user.followers.page(params[:page]).per(10)
    end

  end
end
