module Admins
  class UsersController < Admins::Base
    require 'date'
    before_action :authenticate_admin!, only: %i[show edit update destroy admins_show]
    before_action :set_user, only: %i[show edit update destroy]

    def show
      @profile = @user.profile
      today = Date.today.strftime('%Y%m%d').to_i
    end

    def edit
    end

    def update
      if @user.update(users_params)
        redirect_to admins_users_path, notice: 'ユーザー情報の更新が完了しました'
      else
        render :edit
      end
    end

    def destroy
      if @user.destroy
        flash[:success] = "#{@user.name}のデータを削除しました。"
        redirect_to admins_users_path
      else
        render :index
      end
    end

    def index
      order = { 
        id: params[:ord_id], 
        name: params[:ord_name], 
        email: params[:ord_email], 
        articles: params[:ord_articles],
        posts: params[:ord_posts] 
      }.compact

      filter = {
        name: params[:flt_name], 
        email: params[:flt_email],
        articles_min: params[:flt_articles_min], 
        articles_max: params[:flt_articles_max],
        posts_min: params[:flt_posts_min], 
        posts_max: params[:flt_posts_max]
      }

      @users = if order.count == 1
                 User.sort_filter(order.first,
                   filter)&.page(params[:page])&.per(30)
               else
                 User.all&.page(params[:page])&.per(30)
               end
    end

    def admins_show
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def users_params
      params.require(:user).permit(:name, :email, :password)
    end
  end
end
