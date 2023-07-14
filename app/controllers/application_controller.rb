class ApplicationController < ActionController::Base
  add_flash_types :success, :info, :warning, :danger
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_comment_notifiations

  def after_sign_in_path_for(resource)
    case resource
    when User
      users_dash_boards_path
    when Admin
      admins_dash_boards_path
    when Manager
      managers_tenants_path
    end
  end

  def configure_permitted_parameters
    added_attrs = %i[email name password password_confirmation]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
    devise_parameter_sanitizer.permit :sign_in, keys: added_attrs
  end

  private

  # コメント通知件数を表示するためのメソッド
  def set_comment_notifiations
    if user_signed_in?
      @comment_notifications = TweetComment.where(confirmed: false, recipient_id: current_user.id)
        .where.not(user_id: current_user.id) # user_idがログインユーザーの場合はカウントしない。
        .order(created_at: :desc)
    end
  end
end
