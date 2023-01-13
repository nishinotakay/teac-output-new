module Admins
  class DashBoardsController < Admins::Base
    def index
      @articles = Article.all.order(updated_at: 'DESC').page(params[:page]).per(30)
    end
  end
end
