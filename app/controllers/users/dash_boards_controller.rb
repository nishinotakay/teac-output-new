module Users
  class DashBoardsController < Users::Base
    def index
      params[:order] ||= 'DESC'
      filter = {author: params[:author], title: params[:title], subtitle: params[:subtitle],
        content: params[:content], start: params[:start], finish: params[:finish]}
      if @paginate = filter.compact.blank?
        @articles = current_user.articles.order(created_at: params[:order]).page(params[:page]).per(30) 
      else
        filter[:order] = params[:order]
        @articles = current_user.articles.sort_filter(filter)
      end
    end
  end
end
