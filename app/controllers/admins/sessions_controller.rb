# frozen_string_literal: true

module Admins
  class SessionsController < Devise::SessionsController
    layout 'admins'
    # before_action :configure_sign_in_params, only: [:create]

    # GET /resource/sign_in
    # def new
    #   super
    # end

    # POST /resource/sign_in
    def create
      return super unless params[:tenant_id].present? || session[:tenant_id].present?
      tenant_id = params[:tenant_id] || session[:tenant_id]
      tenant = Tenant.find_by(id: tenant_id)
    
      if tenant
        session[:tenant_id] = tenant_id
        super do |tenant_admin_admin|
          warden.set_user(tenant_admin_admin, scope: :tenant_admin_admin)
        end
      else
        flash[:alert] = "無効なテナントです"
        redirect_to new_tenant_admin_session_path(tenant_id: tenant_id)
      end
    end

    # DELETE /resource/sign_out
    def destroy
      return super unless session[:tenant_id].present?
      warden.logout(:tenant_admin_admin)
      warden.logout(:admin)

      redirect_to new_tenant_admin_admin_session_path(tenant_id: session[:tenant_id])
      session[:tenant_id] = nil
    end

    # protected

    # If you have extra params to permit, append them to the sanitizer.
    # def configure_sign_in_params
    #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
    # end
  end
end
