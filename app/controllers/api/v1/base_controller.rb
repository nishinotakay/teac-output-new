class Api::V1::BaseController < ActionController::API
  before_action :authenticate!

  private

  def authenticate!
    token = request.headers['Authorization']&.split(' ')&.last
    return render_unauthorized unless token

    payload = JwtHelper.decode(token)
    return render_unauthorized unless payload

    role = payload['role']
    id   = payload['id']

    @current_user    = User.find_by(id: id)    if role == 'user'
    @current_admin   = Admin.find_by(id: id)   if role == 'admin'
    @current_manager = Manager.find_by(id: id) if role == 'manager'

    render_unauthorized unless @current_user || @current_admin || @current_manager
  end

  def authenticate_user!
    token = request.headers['Authorization']&.split(' ')&.last
    return render_unauthorized unless token

    payload = JwtHelper.decode(token)
    return render_unauthorized unless payload && payload['role'] == 'user'

    @current_user = User.find_by(id: payload['id'])
    render_unauthorized unless @current_user
  end

  def authenticate_admin!
    token = request.headers['Authorization']&.split(' ')&.last
    return render_unauthorized unless token

    payload = JwtHelper.decode(token)
    return render_unauthorized unless payload && payload['role'] == 'admin'

    @current_admin = Admin.find_by(id: payload['id'])
    render_unauthorized unless @current_admin
  end

  def authenticate_manager!
    token = request.headers['Authorization']&.split(' ')&.last
    return render_unauthorized unless token

    payload = JwtHelper.decode(token)
    return render_unauthorized unless payload && payload['role'] == 'manager'

    @current_manager = Manager.find_by(id: payload['id'])
    render_unauthorized unless @current_manager
  end

  def render_unauthorized
    render json: { error: '認証が必要です' }, status: :unauthorized
  end

  def render_not_found(resource = 'リソース')
    render json: { error: "#{resource}が見つかりません" }, status: :not_found
  end

  def render_bad_request(message)
    render json: { error: message }, status: :bad_request
  end

  def user_json(user)
    profile = user.profile
    {
      id: user.id.to_s,
      name: user.name,
      email: user.email,
      birthday: profile&.birthday&.strftime('%Y-%m-%d'),
      gender: user.gender,
      createdAt: user.created_at.iso8601
    }
  end

  def admin_json(admin)
    {
      id: admin.id.to_s,
      name: admin.name,
      email: admin.email,
      createdAt: admin.created_at.iso8601
    }
  end

  def manager_json(manager)
    {
      id: manager.id.to_s,
      name: manager.name,
      email: manager.email,
      createdAt: manager.created_at.iso8601
    }
  end
end
