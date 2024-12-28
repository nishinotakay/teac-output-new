class ApplicationController < ActionController::Base
  add_flash_types :success, :info, :warning, :danger
  before_action :switch_tenant
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_comment_notifiations
  before_action :set_profile_image, if: :user_signed_in?

  def after_sign_in_path_for(resource)
    if resource.is_a?(User)
      sign_in(:user, resource)
    end

    if resource.is_a?(Admin)
      sign_in(:admin, resource)
    end 

    case resource
    when User
      users_dash_boards_path
    when Admin
      admins_dash_boards_path
    when Manager
      managers_tenants_path
    else
      root_path
    end
  end  

  def after_sign_out_path_for(resource)
    case resource
    when :user
      new_user_session_path
    when :admin
      new_admin_session_path
    when :manager
      new_manager_session_path
    else
      root_path
    end
  end

  def configure_permitted_parameters
    added_attrs = %i[email name password password_confirmation]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
    devise_parameter_sanitizer.permit :sign_in, keys: added_attrs
  end

  def switch_tenant
    tenant_id = get_tenant_id
    current_tenant = Apartment::Tenant.current
    tenant = Tenant.find_by(id: tenant_id)
    if tenant.present?
      return unless authorized_tenant?(tenant)
      Apartment::Tenant.switch!(tenant.name)
      Rails.logger.info("Switched to Tenant: #{Apartment::Tenant.current}")
    else
      check_session_status(current_tenant)
      Apartment::Tenant.reset
      Rails.logger.info("Switched to Single Tenant: Current Tenant is Single_Tenant")
    end
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

  def set_profile_image
    @user_profile_image = current_user.profile&.image.present? ? current_user.profile.image : "user_default.png"
  end

  def get_tenant_id
    params[:tenant_id] || session[:tenant_id] || current_user&.tenant_id || current_admin&.tenant_id
  end

  def authorized_tenant?(tenant)
    return true if !user_signed_in? && session[:tenant_id].nil? ||
                   !admin_signed_in? && session[:tenant_id].nil?

    if user_signed_in? && tenant.has_user?(current_user) || 
      admin_signed_in? && tenant.has_user?(current_admin)
      return true
    else
      flash[:alert] = "不正なテナントへのアクセスのため、ページを表示できませんでした。元のテナントに戻ります"
      return false
    end
  end

  def check_session_status(current_tenant)
    return if BEFORE_LOGIN_SINGLE_TENANT_PATHS.include?(request.path)

    default_tenant = Apartment::Tenant.default_tenant
    if current_tenant != default_tenant && current_user.nil? && session[:tenant_id].nil? ||
       current_tenant != default_tenant && current_admin.nil? && session[:tenant_id].nil?
       flash[:alert] = "セッションが無効です。再度ログインしてください。"
       redirect_to root_path
    end
  end

end
