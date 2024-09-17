class PostDecorator < Draper::Decorator
  delegate_all

  def formatted_likes(current_user)
    if likes.present?
      if current_user&.post_already_liked?(post.id)
        h.content_tag(:i, '', class: 'fa-solid fa-heart mr-2') + likes.count.to_s
      else
        h.content_tag(:i, '', class: 'fa-regular fa-heart mr-2') + likes.count.to_s
      end
    end
  end

  def admin_formatted_likes(current_admin)
      if post.likes.present?
        h.content_tag(:i, '', class: 'fa-solid fa-heart mr-2') + likes.count.to_s
      else
        h.content_tag(:i, '', class: 'fa-regular fa-heart mr-2') + likes.count.to_s
      end
  end

  def formatted_comment_count
    if post_comments.present?
      h.content_tag(:i, '', class: 'fa-regular fa-comment fa-sm ms-auto') + ' ' + post_comments.count.to_s
    end
  end
end
