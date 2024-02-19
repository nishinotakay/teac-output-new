class Users::RelationshipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def create
    current_user.follow(@user)
  end

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
