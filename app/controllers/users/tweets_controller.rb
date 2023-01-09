module Users
  class TweetsController < Users::Base
    def index
      @users = User.all
      @tweets = Tweet.all
      @profiles = Profile.all
    end
  end
end
