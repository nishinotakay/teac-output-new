# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    layout 'users_auth'

    def google_oauth2
      callback_for(:google)
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

  end
end
