class Api::V1::Auth::ManagersController < Api::V1::BaseController
  skip_before_action :authenticate!, only: [:login]

  # POST /api/v1/manager/auth/login
  def login
    manager = Manager.find_by(email: params[:email]&.downcase)
    if manager&.valid_password?(params[:password])
      token = JwtHelper.encode(id: manager.id, role: 'manager')
      render json: { token: token, manager: manager_json(manager) }
    else
      render json: { error: 'メールアドレスまたはパスワードが違います' }, status: :unauthorized
    end
  end

  # DELETE /api/v1/manager/auth/logout
  def logout
    render json: { message: 'ログアウトしました' }
  end

  # GET /api/v1/manager/auth/me
  def me
    render json: { manager: manager_json(@current_manager) }
  end
end
