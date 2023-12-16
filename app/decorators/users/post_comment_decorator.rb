class Users::PostCommentDecorator < ApplicationDecorator
  delegate_all

  def formatted_comment_count
    if post_comments.present?
      h.content_tag(:i, '', class: 'fa-regular fa-comment fa-sm ms-auto') + post_comments.count.to_s  
    end
  end
end
