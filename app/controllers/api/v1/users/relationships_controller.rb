# frozen_string_literal: true

class Api::V1::Users::RelationshipsController < Api::V1::BaseController
  include FollowUserJson

  before_action :authenticate_user!
  before_action :set_user

  # POST /api/v1/users/:user_id/follow
  def create
    relationship = @current_user.active_relationships.build(followed: @user)
    if relationship.save
      render json: { user: user_profile_json(@user) }, status: :created
    else
      render json: { errors: relationship.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    render json: { errors: [I18n.t('activerecord.errors.models.relationship.already_following')] }, status: :unprocessable_entity
  end

  # DELETE /api/v1/users/:user_id/follow
  def destroy
    relationship = @current_user.active_relationships.find_by(followed_id: @user.id)
    return render_not_found('フォロー') unless relationship

    relationship.destroy!
    render json: { user: user_profile_json(@user) }
  end

  private

  # 他テナントは default_scope で見つからず 404 になる
  def set_user
    @user = User.not_cancelled.find_by(id: params[:user_id])
    render_not_found('受講生') unless @user
  end
end
