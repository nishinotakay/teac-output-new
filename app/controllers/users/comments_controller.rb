module Users
  class CommentsController < Users::Base
# class Users::CommentsController < ApplicationController

before_action :authenticate_user!, only: [:create, :destroy]
    def create
      @comment = current_user.comments.new(comment_params)
      if @comment.save
        redirect_back(fallback_location: root_path)  #コメント送信後は、一つ前のページへリダイレクトさせる。
      else
        redirect_back(fallback_location: root_path)  #同上
      end
    end

    def destroy
      @tweet = Tweet.find(params[:tweet_id])
      @comment = Comment.find(params[:id])
      if @comment.destroy
        redirect_to users_tweet_path(@tweet), notice: "コメントを削除しました。"
      else
        flash.now[:alert] = 'コメント削除に失敗しました'
        render users_tweet_path(@tweet)
      end
    end

    private

    def comment_params
      params.require(:comment).permit(:comment_content, :tweet_id)  #formにてpost_idパラメータを送信して、コメントへpost_idを格納するようにする必要がある。
    end
  end
end
