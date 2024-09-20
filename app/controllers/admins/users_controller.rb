module Admins
  class UsersController < Admins::Base
    require 'date'
    before_action :authenticate_admin!, only: %i[show edit update destroy admins_show]
    before_action :set_user, only: %i[show edit update destroy]

    def show
      @profile = @user.profile
      today = Date.today.strftime('%Y%m%d').to_i
    end

    def index
      order = { 
        id: params[:ord_id], 
        name: params[:ord_name], 
        email: params[:ord_email], 
        articles: params[:ord_articles],
        posts: params[:ord_posts], 
        tweets: params[:ord_tweets]
      }.compact

      filter = {
        name: params[:flt_name], 
        email: params[:flt_email],
        articles_min: params[:flt_articles_min], 
        articles_max: params[:flt_articles_max],
        posts_min: params[:flt_posts_min], 
        posts_max: params[:flt_posts_max],
        tweets_min: params[:flt_tweets_min], 
        tweets_max: params[:flt_tweets_max]
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
