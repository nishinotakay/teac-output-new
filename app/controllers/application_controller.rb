class ApplicationController < ActionController::Base
  add_flash_types :success, :info, :warning, :danger
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_comment_notifiations
  before_action :set_profile_image, if: :user_signed_in?
  before_action :switch_tenant, if: :user_signed_in?

  def after_sign_in_path_for(resource)
    if resource.is_a?(User)
      # Userスコープとしてもログインさせる
      sign_in(:user, resource)
      Rails.logger.info("In after_sign_in_path_for: current_user=#{current_user.inspect}, warden_user=#{warden.user(:tenant_user_user).inspect}")
      Rails.logger.info("Session info in after_sign_in_path_for: #{session.inspect}")
    end 
  
    case resource
    when User
      users_dash_boards_path
    when Admin
      admins_dash_boards_path
    when Manager
      managers_tenants_path
    else
      root_path  # デフォルトのパスを設定
    end
  end  

  def after_sign_out_path_for(resource)
    case resource
    when :user
      new_user_session_path
    when :admin
      new_admin_session_path
    when :manager
      root_path
    else
      root_path  # デフォルトのパス
    end
  end

  def configure_permitted_parameters
    added_attrs = %i[email name password password_confirmation]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
    devise_parameter_sanitizer.permit :sign_in, keys: added_attrs
  end

  private

  def set_comment_notifiations
    if user_signed_in?
      @comment_notifications = TweetComment.where(confirmed: false, recipient_id: current_user.id)
        .where.not(user_id: current_user.id)
        .order(created_at: :desc)
    end
  end

  def set_profile_image
    @user_profile_image = current_user.profile&.image.present? ? current_user.profile.image : "user_default.png"
  end

  def switch_tenant  
    tenant_id = session[:tenant_id] || params[:tenant_id] || current_user&.tenant_id
    Rails.logger.info("Before switch_tenant: session=#{session.inspect}, current_user=#{current_user.inspect}")
  
    if tenant_id.present?
      tenant = Tenant.find_by(id: tenant_id)
      if tenant
        Apartment::Tenant.switch!(tenant.name)
        Rails.logger.info("Switched to Tenant: #{Apartment::Tenant.current}")
      else
        Rails.logger.error("Tenant not found: #{tenant_id}")
        raise "Tenant not found"
      end
    else
      Rails.logger.error("Tenant ID is missing")
      raise "Tenant not found"
    end
  end
end
