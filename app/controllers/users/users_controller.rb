module Users
  class UsersController < Users::Base
    before_action :authenticate_user!

    def index
      order = {
        id:       params[:ord_id],
        name:     params[:ord_name],
        email:    params[:ord_email],
        articles: params[:ord_articles],
        posts:    params[:ord_posts]
      }.compact

      filter = {
        name:         params[:flt_name],
        email:        params[:flt_email],
        articles_min: params[:flt_articles_min],
        articles_max: params[:flt_articles_max],
        posts_min:    params[:flt_posts_min],
        posts_max:    params[:flt_posts_max]
      }

      @users = if order.count == 1
                 User.sort_filter(order.first, filter).page(params[:page]).per(30)
               else
                 User.all.includes(:articles, :posts).page(params[:page]).per(30)
               end
    end

    # 管理者側で使用している登録ユーザー詳細画面のアクション、一般ユーザー側でも使用するか要確認
    def show
      @user = User.find(params[:id])
      @profile = current_user.profile
    end
  end
end
