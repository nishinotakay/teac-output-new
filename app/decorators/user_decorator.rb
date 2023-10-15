class UserDecorator < ApplicationDecorator
  delegate_all

  def profile_image
    object.profile&.image.present? ? object.profile.image : "user_default.png"
  end
end
