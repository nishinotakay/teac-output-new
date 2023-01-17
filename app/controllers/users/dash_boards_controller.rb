module Users
  class DashBoardsController < Users::Base
    def index
      filter = {author: params[:author], title: params[:title], subtitle: params[:subtitle], content: params[:content]}
      start = params[:start]
      finish = params[:finish]
      params[:order] ||= 'DESC'
      if @paginate = params[:start].blank? && params[:finish].blank? && filter.compact.blank?
        @articles = current_user.articles.order(created_at: params[:order]).page(params[:page]).per(30) 
      else
        @articles = current_user.articles.order(created_at: params[:order])
        start ||= "2022-01-01".to_date if finish
        finish ||= Date.current if start
        @articles &= current_user.articles.time_filter(start, finish) if start && finish
        @articles &= current_user.articles.multi_filter(filter)
      end
    end
  end
end
