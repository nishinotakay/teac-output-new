module Users
  class SessionsController < Devise::SessionsController
    layout 'users_auth'

    def create
      return super unless params[:tenant_id].present? || session[:tenant_id].present?
      tenant_id = params[:tenant_id] || session[:tenant_id]
      tenant = Tenant.find_by(id: tenant_id)
    
      if tenant
        session[:tenant_id] = tenant_id    
        super do |tenant_user_user|
          warden.set_user(tenant_user_user, scope: :tenant_user_user)
        end
      else
        flash[:alert] = "無効なテナントです"
        redirect_to new_tenant_user_user_session_path(tenant_id: tenant_id)
      end
    end

    def destroy
      return super unless session[:tenant_id].present?
      warden.logout(:tenant_user_user)

      redirect_to new_tenant_user_user_session_path(tenant_id: session[:tenant_id])
      session[:tenant_id] = nil
    end
  end
end
