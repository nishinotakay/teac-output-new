module Admins
  class ProfilesController < Admins::Base
    require 'date'
    before_action :authenticate_admin!, only: %i[new create edit update destroy users_show user_edit user_destroy admins_show]
    before_action :find_profile, only: %i[edit update destroy ]
    
    def users_show
      @user = User.find(params[:format]) 
      @profile = @user.profile
      today = Date.today.strftime('%Y%m%d').to_i
      learning_startday = @profile.learning_start.strftime('%Y%m%d').to_i if @profile.present? && @profile.learning_start? 
      @study_period = (today - learning_startday) / 10000 if learning_startday.present?
      birthday = @profile.birthday.strftime('%Y%m%d').to_i if @profile.present? && @profile.birthday?
      @age = (today - birthday) / 10000 if birthday.present?
    end
    
    def users_edit
      @user = User.find(params[:format]) 
    end
    
    def user_destroy
      # データの削除
      @user = User.find(params[:format]) 
      if @user.destroy
        flash[:success] = "#{@user.name}のデータを削除しました。"
        # 一覧ページへリダイレクト
        redirect_to users_profiles_path
      else
        render :index
      end
    end

    def index
      @users = User.all.page(params[:page]).per(30)
      @profiles = Profile.all
    end

    def admins_show
    end

    def new
      @profile = Profile.new
    end

    def edit; end

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

    def destroy
      # データの削除
      if @profile.destroy
        flash[:success] = "#{@profile.name}のデータを削除しました。"
        # 一覧ページへリダイレクト
        redirect_to users_profiles_path
      else
        render :index
      end
    end

    private

    def find_profile
      @profile = Profile.find(params[:id])
    end

    def profile_params
      params.require(:profile).permit(
        :name, :learning_history, :purpose, :image, :created_at, :learning_start
      )
    end
  end
end
