class Api::V1::Admin::UsersController < Api::V1::BaseController
  before_action :authenticate_admin!
  before_action :set_user, only: [:show, :update, :destroy]

  # GET /api/v1/admin/users
  def index
    users = User.includes(:profile, :articles, :posts, :tweets).order(created_at: :desc)
    render json: { users: users.map { |u| admin_user_json(u) } }
  end

  # GET /api/v1/admin/users/:id
  def show
    render json: { user: admin_user_json(@user) }
  end

  # PATCH /api/v1/admin/users/:id
  def update
    if @user.update(user_update_params)
      render json: { user: admin_user_json(@user) }
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/admin/users/:id
  def destroy
    @user.destroy
    render json: { message: '削除しました' }
  end

  private

  def set_user
    @user = User.find_by(id: params[:id])
    render_not_found('ユーザー') unless @user
  end

  def user_update_params
    params.permit(:name, :email, :gender, :age)
  end

  def admin_user_json(user)
    profile = user.profile
    {
      id: user.id.to_s,
      name: user.name,
      email: user.email,
      birthday: profile&.birthday&.strftime('%Y-%m-%d'),
      gender: user.gender,
      age: user.age,
      articlesCount: user.articles.size,
      postsCount: user.posts.size,
      tweetsCount: user.tweets.size,
      createdAt: user.created_at.iso8601
    }
  end
end
