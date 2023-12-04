class PostDecorator < Draper::Decorator
  delegate_all

  def formatted_likes(current_user)
    if likes.present?
      if current_user&.post_already_liked?(post.id)
        h.content_tag(:i, '', class: 'fa-solid fa-heart ml-4 mr-2') + likes.count.to_s
      else
        h.content_tag(:i, '', class: 'fa-regular fa-heart ml-4 mr-2') + likes.count.to_s
      end
    end
  end

end
