module Admins
  class UsersController < Admins::Base
    require 'date'
    before_action :authenticate_admin!, only: %i[new create edit update destroy admins_show]
    before_action :find_profile, only: %i[edit update destroy]

    def show
      @user = User.find(params[:id])
      @profile = @user.profile
      today = Date.today.strftime('%Y%m%d').to_i

      learning_startday = @profile.learning_start.strftime('%Y%m%d').to_i if @profile.present? && @profile.learning_start?
      @study_period = (today - learning_startday) / 10000 if learning_startday.present?

      birthday = @profile.birthday.strftime('%Y%m%d').to_i if @profile.present? && @profile.birthday?
      @age = (today - birthday) / 10000 if birthday.present?
    end

    def edit
      @user = User.find(params[:id])
    end

    def destroy
      @user = User.find(params[:id])

      if @user.destroy
        flash[:success] = "#{@user.name}のデータを削除しました。"
        # ユーザー 一覧ページへリダイレクト
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

      @profiles = Profile.all
    end

    def admins_show
    end

    def new
      @profile = Profile.new
    end

    def create
      @profile = Profile.new(profile_params)
      @profile.user = current_user
      if @profile.save
        redirect_to users_profiles_path, notice: 'プロフィール情報の入力が完了しました'
      else
        render :new
      end
    end

    def update
      if @profile.update(profile_params)
        redirect_to users_profile_path, notice: 'プロフィール情報の更新が完了しました'
      else
        render :edit
      end
    end

    private

    def find_profile
      @user = User.find(params[:id])
      @profile = @user.profile
    end

    def profile_params
      params.require(:profile).permit(
        :name, :learning_history, :purpose, :image, :created_at, :learning_start
      )
    end
  end
end

