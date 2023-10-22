module Users
  class DashBoardsController < Users::Base
    def index
      params[:order] ||= 'DESC'
      # paramsを元にfilterを作成する
      filter = {
        author:   params[:author],
        title:    params[:title],
        subtitle: params[:subtitle],
        content:  params[:content],
        start:    params[:start],
        finish:   params[:finish],
        order:    params[:order]
      }
  
      # filterを元に記事一覧を取得する
      @articles = current_user.articles.paginated_and_sort_filter(filter).page(params[:page])
    end
  end
end
