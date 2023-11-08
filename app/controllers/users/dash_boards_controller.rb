module Users
  class DashBoardsController < Users::Base
    
    def index
      filter = {
        author:   params[:author],
        title:    params[:title],
        subtitle: params[:subtitle],
        content:  params[:content],
        start:    params[:start],
        finish:   params[:finish],
        order:    params[:order] ||= 'DESC'
      }
  
      @articles = current_user.articles.paginated_and_sort_filter(filter).page(params[:page]).per(30)

      respond_to do |format|
        format.any
        format.html
        format.json { render json: @articles }
      end
    end
  end
end
