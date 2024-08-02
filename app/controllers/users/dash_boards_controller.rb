module Users
  class DashBoardsController < Users::Base
    skip_before_action :authenticate_user!, only: %i[index], if: :admin_signed_in?
    
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
      
      if current_admin.present? && current_user.nil?
        user = User.find(params[:user_id])
        @articles = user.articles.paginated_and_sort_filter(filter).page(params[:page]).per(30)
      else
        @articles = current_user.articles.paginated_and_sort_filter(filter).page(params[:page]).per(30)

      respond_to do |format|
        format.any
        format.html
        format.json { render json: @articles }
      end
      end

      @folders = current_user.folders if current_user.folders.present?

    end
  end
end
