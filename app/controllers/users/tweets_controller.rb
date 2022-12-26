module Users
  class TweetsController < Users::Base
    def index
      @tweets = Tweet.all
    end
  end
end
