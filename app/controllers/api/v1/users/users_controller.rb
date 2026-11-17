# frozen_string_literal: true

class Api::V1::Users::UsersController < Api::V1::BaseController
  include FollowUserJson

  NEWEST_FOLLOW_FIRST = 'relationships.created_at DESC, relationships.id DESC'

  before_action :authenticate_user!
  before_action :set_user, only: %i[show followings followers]

  # GET /api/v1/users
  def index
    render_user_rows(User.not_cancelled.order(:id))
  end

  # GET /api/v1/users/:id
  def show
    render json: { user: user_profile_json(@user) }
  end

  # GET /api/v1/users/:id/followings
  def followings
    render_user_rows(@user.followings.not_cancelled.order(NEWEST_FOLLOW_FIRST))
  end

  # GET /api/v1/users/:id/followers
  def followers
    render_user_rows(@user.followers.not_cancelled.order(NEWEST_FOLLOW_FIRST))
  end

  private

  # 他テナントは default_scope で見つからず 404 になる
  def set_user
    @user = User.not_cancelled.find_by(id: params[:id])
    render_not_found('受講生') unless @user
  end

  def render_user_rows(users)
    followed_user_ids = @current_user.active_relationships.pluck(:followed_id)
    render json: { users: users.map { |user| user_row_json(user, followed_user_ids) } }
  end
end
