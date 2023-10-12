class UserDecorator < ApplicationDecorator
  delegate_all

  def profile_image
    object.profile&.image ? object.profile.image : "user_default.png"
  end
end
