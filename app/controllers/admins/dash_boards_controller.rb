module Admins
  class DashBoardsController < Admins::Base
    def index
      params[:order] ||= 'DESC'
      filter = {
        author:   params[:author],
        title:    params[:title],
        subtitle: params[:subtitle],
        content:  params[:content],
        start:    params[:start],
        finish:   params[:finish]
      }

      if (@paginate = filter.compact.blank?)
        @articles = current_admin.articles.order(created_at: params[:order]).page(params[:page]).per(30)
      else
        (@paginate = filter.compact.present?)
        filter[:order] = params[:order]
        @articles = current_admin.articles.sort_filter(filter).page(params[:page]).per(30)
      end

      @categories = Category.pluck(:name, :id)
      @categories << ["一般記事", "normal"]
    end
  end
end
