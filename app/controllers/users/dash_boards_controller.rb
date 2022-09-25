module Users
  class DashBoardsController < Users::Base
    def index
      @articles = current_user.articles.order(updated_at: 'DESC')
    end
  end
end
