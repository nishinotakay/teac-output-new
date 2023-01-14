module Users
  class DashBoardsController < Users::Base
    def index
      @profiles = Profile.all
      @articles = current_user.articles.order(updated_at: 'DESC').page(params[:page]).per(30)
    end
  end
end
