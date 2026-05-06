# ユーザー向けフォロー関係コントローラ: ユーザーが他のユーザーをフォロー・アンフォローするアクションを提供する

class Users::RelationshipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  # 対象ユーザーをフォローする
  def create
    current_user.follow(@user)
  end

  # 対象ユーザーのフォローを解除する
  def destroy
    current_user.unfollow(@user)
  end

  private

    def relationship_params
      params.permit(:user_id)
    end

    def set_user
      @user = User.find(relationship_params[:user_id])
    end

end
