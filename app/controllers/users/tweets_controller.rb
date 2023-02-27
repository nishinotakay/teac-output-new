module Users
  class TweetsController < Users::Base
    # Userがログインしていないと、投稿を作成・編集・削除できない
    before_action :authenticate_user!, only: [:show, :index, :new, :create, :edit, :update, :destroy, :index_user]
    before_action :set_tweet, only: [:show, :edit, :update, :destroy]
    # 投稿をしたユーザー以外は編集・削除できない
    before_action :correct_tweet_user, only: [:edit, :update, :destroy]

    def index
      @users = User.all
      @tweets = Tweet.all
    end

    def show
      @comments = @tweet.comments.all
      @comment = current_user.comments.new
    end

    def new
      @tweet = current_user.tweets.new
    end

    def create
      @tweet =current_user.tweets.new(tweet_params)
      flash[:success] = "つぶやきを作成しました。" if @tweet.save
      redirect_back(fallback_location: root_path)
    end

    def edit
    end

    def update
      if @tweet.update(tweet_params)
        @tweet.save
        flash[:success] = "編集成功しました。"
        redirect_to users_tweets_url
      else
        render :edit
      end
    end

    def destroy
      if @tweet.destroy
        flash[:success] = "削除に成功しました。"
        redirect_to users_tweets_url
      end
    end

    def index_user
      @tweets = Tweet.where(user_id: params[:id])
      @user = User.find(params[:id])
    end

    private
      
    def tweet_params
      params.require(:tweet).permit(:post)
    end

    # beforeフィルター

    def set_tweet
      @tweet = Tweet.find(params[:id])
    end

    def correct_tweet_user
      @tweet = Tweet.find(params[:id])
      redirect_to root_url if @tweet.user != current_user
    end
  end
end
