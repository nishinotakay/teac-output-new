require 'rinku'

module Users
  class TweetsController < Users::Base
    # Userがログインしていないと、投稿を作成・編集・削除できない
    before_action :authenticate_user!, only: %i[show index new create edit update destroy index_user create_comment]
    before_action :set_tweet, only: %i[show edit update destroy]
    # 投稿をしたユーザーでないと編集・削除できない
    before_action :correct_tweet_user, only: %i[edit update destroy]
    skip_before_action :authenticate_user!, only: %i[show], if: :admin_signed_in?

    def index
      fetch_tweets_and_images
      @comment = TweetComment.new
    end

    def show
      @tweet_comments = @tweet.tweet_comments.order(created_at: :desc)
      @tweet_comment = current_user.tweet_comments.new unless current_admin.present?
    end

    def new
      @tweet = current_user.tweets.new
    end

    def create
      @tweet = current_user.tweets.new(tweet_params)
      if @tweet.save
        flash[:success] = 'つぶやきを作成しました。'
      else
        flash[:error] = @tweet.errors.full_messages.join('・')
      end
      redirect_back(fallback_location: root_path)
    end

    def edit
      respond_to do |format|
        format.js
      end
    end

    def update
      if @tweet.update(tweet_params)
        flash[:success] = '編集成功しました。'
        redirect_to users_tweets_url
      else
        render :edit
      end
    end

    def destroy
      if @tweet.destroy
        flash[:success] = '削除に成功しました。'
        redirect_to users_tweets_url
      end
    end

    def index_user
      @user = User.find(params[:id])
      fetch_tweets_and_images(@user.id)
    end

    def create_comment
      @comment = current_user.tweet_comments.new(comment_params)
      if @comment.save
        flash[:success] = 'コメントが投稿されました'
      else
        flash[:danger] = @comment.errors.full_messages.join('・')
      end
      redirect_back(fallback_location: users_tweets_path)
    end

    private

    def tweet_params
      params.require(:tweet).permit(:post, images: [])
    end

    def comment_params
      params.require(:tweet_comment).permit(:content, :tweet_id)
    end

    def fetch_tweets_and_images(user_id = nil)
      filter = Tweet.build_filter(params)
      @tweets = Tweet.apply_and_sort_query(filter, user_id, params[:page])
      @tweets_with_images = Tweet.tweet_and_image(@tweets)
    end

    # beforeフィルター
    def set_tweet
      @tweet = Tweet.find(params[:id])
    end

    def correct_tweet_user
      if @tweet.user != current_user
        flash[:alert] = 'アクセスできません'
        redirect_to users_dash_boards_path
      end
    end
  end
end