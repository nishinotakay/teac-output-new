# frozen_string_literal: true

# 他の受講生に見せる JSON（メールアドレス・誕生日は出さない）
module FollowUserJson
  extend ActiveSupport::Concern

  private

  def user_profile_json(user)
    {
      id:                    user.id.to_s,
      name:                  user.name,
      followingsCount:       user.followings.not_cancelled.count,
      followersCount:        user.followers.not_cancelled.count,
      followedByCurrentUser: @current_user.active_relationships.exists?(followed_id: user.id),
      isCurrentUser:         user.id == @current_user.id
    }
  end

  def user_row_json(user, followed_user_ids)
    {
      id:                    user.id.to_s,
      name:                  user.name,
      followedByCurrentUser: followed_user_ids.include?(user.id),
      isCurrentUser:         user.id == @current_user.id
    }
  end
end
