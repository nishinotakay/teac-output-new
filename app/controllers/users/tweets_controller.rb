module Users
  class TweetsController < Users::Base
    # Userがログインしていないと、投稿を作成・編集・削除できない
    before_action :authenticate_user!, only: [:show, :index, :new, :create, :edit, :update, :destroy, :index_user]

    def index
      @users = User.all
      @tweets = Tweet.all.order(created_at: :desc)
    end

    def show
      @tweet = Tweet.find(params[:id])
      @comments = @tweet.comments.all.order(created_at: :desc)
      @comment = current_user.comments.new
    end

    def new
      @tweet = current_user.tweets.new
    end

    def create
      @tweet =current_user.tweets.new(tweet_params)
      if @tweet.save
        flash[:success] = "つぶやきを作成しました。"
      else
        flash[:danger ] = @tweet.errors.full_messages.join
      end
      redirect_back(fallback_location: root_path)
    end

    def edit
      @tweet = Tweet.find(params[:id])
    end

    def update
      @tweet = Tweet.find(params[:id])
      if @tweet.update(tweet_params)
        @tweet.save
        flash[:success] = "編集成功しました。"
        redirect_to users_tweets_url
      else
        render :edit
      end
    end

    def destroy
      @tweet = Tweet.find(params[:id])
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
  end
end
