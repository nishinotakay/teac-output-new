# frozen_string_literal: true

class ApplicationController < ActionController::Base
  add_flash_types :success, :info, :warning, :danger
  # ログイン済ユーザーのみにアクセスを許可する
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_current_user 

  # protect_from_forgery
  def after_sign_in_path_for(resource)#usersコントローラーのshowアクションを呼び出すパスを設定  ここに追加するのか？
    users_show_path
  end

  before_action :set_current_user

  def after_sign_in_path_for(resource)
    case resource
    when User
      users_dash_boards_path
    when Admin
      admins_dash_boards_path
    when Manager
      managers_dash_boards_path
    end
  end

  def configure_permitted_parameters
    added_attrs = %i[email name password password_confirmation]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
    devise_parameter_sanitizer.permit :sign_in, keys: added_attrs
  end

  def set_current_user
    @current_user = User.find_by(id: session[user_session])
  end
end
