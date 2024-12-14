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
    when :tenant_user_user
      new_tenant_user_user_session_path
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
    tenant_id = params[:tenant_id] || 
                session[:tenant_id] || 
                current_user&.tenant_id
    
    Rails.logger.info "=== Tenant Switch Debug ==="
    Rails.logger.info "Current User: #{current_user.inspect}"
    Rails.logger.info "Session: #{session.to_h}"
    Rails.logger.info "=== Current User ==="
    Rails.logger.info("current_user.tenant_id: #{current_user&.tenant_id}")
    Rails.logger.info("tenant_user_user.tenant_id: #{current_tenant_user_user&.tenant_id}")
    Rails.logger.info("session[:tenant_id]: #{session[:tenant_id]}")
    Rails.logger.info("params[:tenant_id]: #{ params[:tenant_id]}")
    Rails.logger.info("tenant_id: #{tenant_id}")

    if tenant_id.present?
      tenant = Tenant.find_by(id: tenant_id)
    elsif current_user.present?
      tenant = Tenant.find_by(id: current_user.tenant_id)
    else
      tenant = Tenant.find_by(id: session[:tenant_id])
    end
    
    if tenant
      Apartment::Tenant.switch!(tenant.name)
      Rails.logger.info("Switched to Tenant: #{Apartment::Tenant.current}")
    end

    if request.path == root_path || 
       request.path == new_user_session_path ||
       request.path == new_user_registration_path ||
       request.path == new_user_password_path ||
       request.path == new_user_confirmation_path
       Apartment::Tenant.reset
       Rails.logger.info("Switched to Single Tenant: Current Tenant is Single_Tenant")
    end
  end
end
