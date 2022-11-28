module Admins
  class DashBoardsController < Admins::Base
    def index
      @articles = Article.all.order(updated_at: 'DESC')
    end
  end
end
