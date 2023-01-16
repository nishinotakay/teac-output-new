module Users
  class DashBoardsController < Users::Base
    def index
      filter = {author: params[:author], title: params[:title], subtitle: params[:subtitle], content: params[:content]}
      params[:order] ||= 'DESC'
      if @paginate = params[:start].blank? && params[:finish].blank? && filter.compact.blank?
        @articles = current_user.articles.order(created_at: params[:order]).page(params[:page]).per(30) 
      else
        @articles = current_user.articles.order(created_at: params[:order])
        params[:start] ||= "2022-01-01".to_date if params[:finish]
        params[:finish] ||= Date.current if params[:start]
        @articles &= current_user.articles.time_filter(params[:start], params[:finish]) if params[:start] && params[:finish]
        @articles &= current_user.articles.multi_filter(filter)
      end
    end
  end
end
