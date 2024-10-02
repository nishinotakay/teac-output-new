class TweetDecorator < Draper::Decorator
  delegate_all
  def formatted_likes(current_user)
    if likes.present?
      if current_user&.tweet_already_liked?(tweet.id)
        h.content_tag(:i, '', class: 'fa-solid fa-heart mr-2') + likes.count.to_s
      else
        h.content_tag(:i, '', class: 'fa-regular fa-heart mr-2') + likes.count.to_s
      end
    end
  end
  def admin_formatted_likes(current_admin)
    if tweet.likes.present?
      h.content_tag(:i, '', class: 'fa-solid fa-heart mr-2') + likes.count.to_s
    else
      h.content_tag(:i, '', class: 'fa-regular fa-heart mr-2') + likes.count.to_s
    end
  end
  def formatted_comment_count
    if tweet_comments.present?
      h.content_tag(:i, '', class: 'fa-regular fa-comment fa-sm ms-auto') + ' ' + tweet_comments.count.to_s
    end
  end
end