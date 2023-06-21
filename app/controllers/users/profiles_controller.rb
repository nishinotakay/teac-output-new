module Users
  class ProfilesController < Users::Base
    require 'date'
    before_action :authenticate_user!, only: %i[new create edit update destroy]
    before_action :find_profile, only: %i[show double_registration edit update destroy]
    # before_action :double_registration, only: %i[create]

    def index
      order = {name: params[:ord_name], purpose: params[:ord_purpose], learning_start: params[:ord_learning_start]}.compact
      filter = {name: params[:flt_name], purpose: params[:flt_purpose], learning_start: params[:flt_learning_start]}.compact
      @users = order.count == 1 ? User.sort_filter(order.first, filter)&.page(params[:page]).per(30) : User.all&.page(params[:page]).per(30)
      @profiles = Profile.sort_filter(order, filter).page(params[:page]).per(30)
    end

    def show
      today = Date.today.strftime('%Y%m%d').to_i
      learning_startday = @profile.learning_start.strftime('%Y%m%d').to_i if @profile.present? && @profile.learning_start? 
      @study_period = (today - learning_startday) / 10000 if learning_startday.present?
      birthday = @profile.birthday.strftime('%Y%m%d').to_i if @profile.present? && @profile.birthday?
      @age = (today - birthday) / 10000 if birthday.present?
    end

    def new
      @profile = current_user.build_profile
    end

    def edit
      if @user != @current_user
        redirect_to users_profiles_path, notice: '編集権限がありません'
      end
    end

    def create
      @profile = current_user.build_profile(profile_params)
      @profile.name = current_user.name
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
      # if @profile
      #   # binding.pry
      #   redirect_to users_profiles_path, notice: 'プロフィール情報は入力済です'
      # else
      # end
    end

    # def double_registration
    #   # @profile = Profile.find(params[:id])
    #   if @profile.present?
    #     redirect_to users_profiles_path, notice: 'プロフィール情報は入力済です'
    #   else
    #     # render :show
    #   end
    # end  

    def profile_params
      params.require(:profile).permit(
        :purpose, :image, :created_at, :learning_start, :birthday, :gender
      ).merge(user_id: current_user.id)
    end
  end
end
