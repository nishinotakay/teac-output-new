module Users
  class TweetsController < Users::Base
    def index
      @users = User.all
      @tweets = Tweet.all
    end

    def new
      @tweet = current_user.tweets.new
    end

    def create
      @tweet =current_user.tweets.new(tweet_params)
      if @tweet.save
        flash[:success] = "つぶやきを作成しました。"
        redirect_to users_tweets_url(current_user)
      else
        render :new
      end 
    end

    private
      
      def tweet_params
        params.require(:tweet).permit(:post)
      end
  end
end
