# class Users::TweetsController < ApplicationController
#   def index
#     binding.pry
#     @tweets = Tweet.all
#   end
# end

module Users
  class TweetsController < Users::Base
    def index
      @tweets = Tweet.all
    end
  end
end
