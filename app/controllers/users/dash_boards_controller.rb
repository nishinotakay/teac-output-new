module Users
  class DashBoardsController < Users::Base
    def index
      @articles = current_user.articles
    end
  end
end
