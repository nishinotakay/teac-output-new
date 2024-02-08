module Users
  class ProfilesController < Users::Base
    require 'date'
    before_action :authenticate_user!, only: %i[new create edit update destroy]
    before_action :find_profile, only: %i[show edit update destroy]

    def index
      sort_and_filter_params = Profile.get_sort_and_filter_params(params)
      @users = sort_and_filter_params[:order].count == 1 ? User.sort_filter(sort_and_filter_params[:order].first, sort_and_filter_params[:filter]).page(params[:page]).per(30) : User.all.page(params[:page]).per(30)
      default_order = { registration_date: 'DESC' }
      sort_order = sort_and_filter_params[:order].presence || default_order
      @profiles = Profile.sort_filter(sort_order, sort_and_filter_params[:filter]).page(params[:page]).per(30)
    end

    def show
      today = Date.today.strftime('%Y%m%d').to_i
      learning_startday = @profile.learning_start.strftime('%Y%m%d').to_i if @profile.present? && @profile.learning_start?
      @study_period = (today - learning_startday) / 10000 if learning_startday.present?
      birthday = @profile.birthday.strftime('%Y%m%d').to_i if @profile.present? && @profile.birthday?
      @age = (today - birthday) / 10000 if birthday.present?
      @user = @profile.user
    end

    def new
      @profile = current_user.build_profile
    end

    def edit
      if @profile.id != current_user.profile.id
        redirect_to users_profiles_path, notice: '編集権限がありません'
      end
    end

    def create
      @profile = current_user.build_profile(profile_params)
      if @profile.save
        @profile.user.update(profile_params[:user_attributes])
        redirect_to users_profile_path(current_user.profile), notice: 'プロフィールを作成しました'
      else
        render :new
      end
    end
    
    def update
      if @profile.update(profile_params)
        redirect_to users_profile_path, notice: 'プロフィール情報を更新しました'
      else
        render :edit
      end
    end

    def destroy
      if @profile.destroy
        flash[:success] = "#{@profile.name}のデータを削除しました。"
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
        :name, :image, :birthday, :gender, :registration_date, :hobby,
        user_attributes: %i[id name]
      ).merge(user_id: current_user.id)
    end
  end
end
