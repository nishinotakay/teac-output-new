# app/controllers/users/dash_boards_controller.rb
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
        if params[:user_id].present?
          user = User.find_by(id: params[:user_id])
          if user.present?
            @articles = user.articles.paginated_and_sort_filter(filter).page(params[:page]).per(30)
          else
            flash[:alert] = "User not found"
            @articles = Article.none.page(params[:page]).per(30) # 空の結果を返す
          end
        else
          flash[:alert] = "User ID is missing"
          @articles = Article.none.page(params[:page]).per(30) # 空の結果を返す
        end
      elsif current_user.present?
        @articles = current_user.articles.paginated_and_sort_filter(filter).page(params[:page]).per(30)
      else
        flash[:alert] = "No user found"
        @articles = Article.none.page(params[:page]).per(30) # 空の結果を返す
      end

      respond_to do |format|
        format.any
        format.html
        format.json { render json: @articles }
      end
    end
  end
end
