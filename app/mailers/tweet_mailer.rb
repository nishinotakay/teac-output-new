# つぶやきメーラー: つぶやきに新規コメントが付いた際にツイートオーナーへ通知メールを送信する

class TweetMailer < ApplicationMailer
  def comment_notification(tweet_owner, commenter, comment_body, tweet_url)
    @tweet_owner = tweet_owner
    @commenter = commenter
    @comment_body = comment_body
    @tweet_url = tweet_url

    mail(to: @tweet_owner.email, subject: 'Your tweet has a new comment!')
  end
end
