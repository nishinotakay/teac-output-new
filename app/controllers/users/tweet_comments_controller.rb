module Users
  class TweetCommentsController < Users::Base
    before_action :authenticate_user!, only: %i[create destroy update]

    def create
      @tweet_comment = current_user.tweet_comments.new(tweet_comment_params)
      if @tweet_comment.save
        redirect_to users_tweet_path(@tweet_comment.tweet), notice: 'コメントを投稿しました。'
      else
        redirect_to users_tweet_path(@tweet_comment.tweet), alert: @tweet_comment.errors.full_messages.join("\n")
      end
    end

    def destroy
      @tweet = Tweet.find(params[:tweet_id])
      @tweet_comment = current_user.tweet_comments.find_by(tweet_id: @tweet.id)
      if @tweet_comment.destroy
        redirect_to users_tweet_path(@tweet_comment), notice: 'コメントを削除しました。'
      else
        flash.now[:alert] = 'コメント削除に失敗しました'
        render users_tweet_path(@tweet_comment)
      end
    end

    def update
      @tweet = Tweet.find(params[:tweet_id])
      @tweet_comment = current_user.tweet_comments.find_by(id: params[:id], tweet_id: @tweet.id)
      if @tweet_comment.nil?
        flash[:alert] = 'コメントが見つかりませんでした。'
      elsif @tweet_comment.update(tweet_comment_params)
        flash[:success] = 'コメントを更新しました。'
      else
        flash[:danger] = 'コメントの更新に失敗しました。'
      end
      redirect_to users_tweet_path(@tweet_comment)
    end

    # 未確認の通知を確認するアクション
    def confirmed_notification
      @tweet = Tweet.find(params[:tweet_id])
      @tweet_comment = @tweet.comments.find(params[:id])
      @tweet_comment.update(confirmed: true)
      redirect_to users_tweet_path(@tweet, anchor: "comment-#{@tweet_comment.id}")
    end

    private

    def tweet_comment_params
      params.require(:tweet_comment).permit(:comment_content, :tweet_id, :recipient_id, :confirmed)  # formにてtweet_idパラメータを送信して、コメントへtweet_idを格納するようにする必要がある。
    end
  end
end
