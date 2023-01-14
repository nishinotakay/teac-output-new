module Users
  class TweetsController < Users::Base
    def index
      @users = User.all
      @tweets = Tweet.all
    end
  end
end
