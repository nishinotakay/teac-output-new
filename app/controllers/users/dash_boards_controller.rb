module Users
  class DashBoardsController < Users::Base
    def index
      @articles = current_user.articles.order(updated_at: 'DESC')
      @profiles = Profile.all
    end
  end
end
