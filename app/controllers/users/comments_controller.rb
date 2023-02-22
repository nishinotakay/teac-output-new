module Users
  class CommentsController < Users::Base
before_action :authenticate_user!, only: [:create, :destroy, :update]
    def create
      @comment = current_user.comments.new(comment_params)
      if @comment.save
        redirect_to users_tweet_path(@comment.tweet), notice: "コメントを投稿しました。"
      else
        redirect_to users_tweet_path(@comment.tweet), alert: @comment.errors.full_messages.join("\n")
      end
    end

    def destroy
      @tweet = Tweet.find(params[:tweet_id])
      @comment = current_user.comments.find_by(tweet_id: @tweet.id)
      if @comment.destroy
        redirect_to users_tweet_path(@tweet), notice: "コメントを削除しました。"
      else
        flash.now[:alert] = 'コメント削除に失敗しました'
        render users_tweet_path(@tweet)
      end
    end

    def update
      @tweet = Tweet.find(params[:tweet_id])
      @comment = current_user.comments.find_by(id: params[:id], tweet_id: @tweet.id)
      if @comment.nil?
        flash[:alert] = "コメントが見つかりませんでした。"
        redirect_to users_tweet_path(@tweet)
      else
        if @comment.update(comment_params)
          flash[:success] = "コメントを更新しました。"
          redirect_to users_tweet_path(@tweet)
        else
          flash[:danger] = "コメントの更新に失敗しました。"
          redirect_to users_tweet_path(@tweet)
        end
      end
    end

    private

    def comment_params
      params.require(:comment).permit(:comment_content, :tweet_id)  #formにてtweet_idパラメータを送信して、コメントへtweet_idを格納するようにする必要がある。
    end
  end
end
