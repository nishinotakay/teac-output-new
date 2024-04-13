# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    layout 'users_auth'

    # You should also create an action method in this controller like this:
    # def twitter
    # end
    def line
      # ここにLINE認証後の処理を記述します。
      # 例: ユーザー情報を取得し、データベースに保存する、
      #     セッションを作成する、リダイレクトを行うなど。
      basic_action
    end

    def google_oauth2
      callback_for(:google)
    end

    def facebook
      callback_for(:facebook)
    end

    def callback_for(provider)
      @user = User.from_omniauth(request.env["omniauth.auth"])

      unless @user.confirmed?
        @user.confirmed_at = Time.now
        @user.save
      end

      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: "#{provider.capitalize}") if is_navigational_format?
    end

    def failure
      redirect_to root_path
    end

    # The path used when OmniAuth fails
    # def after_omniauth_failure_path_for(scope)
    #   super(scope)
    # end

    private
    def basic_action
      @omniauth = request.env["omniauth.auth"]
      if @omniauth.present?
        @profile = User.find_or_initialize_by(provider: @omniauth["provider"], uid: @omniauth["uid"])
        if @profile.new_record? || !@profile.confirmed?
          email = @omniauth["info"]["email"] || fake_email(@omniauth["uid"], @omniauth["provider"])
          @profile.assign_attributes(email: email, name: @omniauth["info"]["name"], password: Devise.friendly_token[0, 20])

          @profile.skip_confirmation! # メール確認をスキップ
          @profile.save!
        end
        @profile.set_values(@omniauth)
        sign_in(:user, @profile)
      end
      flash[:notice] = "ログインしました"
      redirect_to root_path
    end

    def fake_email(uid, provider)
      "#{uid}-#{provider}@example.com"
    end

  end
end
