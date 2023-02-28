module Admins
  class DashBoardsController < Admins::Base
    def index
      params[:order] ||= 'DESC'
      @articles = Article.order(created_at: params[:order]).page(params[:page]).per(30) 
    end
  end
end
