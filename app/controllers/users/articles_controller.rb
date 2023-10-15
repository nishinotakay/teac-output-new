# frozen_string_literal: true

module Users
  class ArticlesController < Users::Base
    protect_from_forgery
    before_action :check_article_owner, only: %i[edit update destroy]
    before_action :set_article, except: %i[index show new create image]
    before_action :set_dashboard, only: %i[show new create edit update destroy]

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
      @articles = Article.paginated_and_sort_filter(filter).page(params[:page])
    end

    def show
      @article = Article.find(params[:id])
      @article_comments = @article.article_comments.all.order(created_at: 'DESC')
      @article_comment = current_user.article_comments.new
    end

    def new
      @article = current_user.articles.new
    end

    def create
      @article = current_user.articles.new(article_params)
      if @article.save
        flash[:notice] = '記事を作成しました。'
        redirect_to users_article_url(@article, dashboard: params[:dashboard], page: params[:page])
      else
        flash.now[:alert] = '記事の作成に失敗しました。'
        render :new
      end
    end

    def edit
      @show = params[:show].present?
    end

    def update
      if @article.update(article_params)
        flash[:notice] = '記事を編集しました。'
        redirect_to users_article_url(@article, dashboard: params[:dashboard], page: params[:page])
      else
        flash.now[:alert] = '記事の編集に失敗しました。'
        render :edit
      end
    end

    def destroy
      flash[:notice] = '記事を削除しました。'
      @article.destroy
      if @dashboard
        redirect_to users_dash_boards_path(current_user, page: params[:page])
      else
        redirect_to users_articles_path(page: params[:page])
      end
    end

    def image
      if current_user.id == params[:user_id].to_i
        @article = current_user.articles.new(params.permit(:image))
        render json: { name: @article.image.identifier, url: @article.image.url }
      else
        render json: { error: '画像の挿入に失敗しました。' }, status: :unauthorized
      end
    end

    private

    def article_params
      params.require(:article).permit(:title, :sub_title, :content)
    end

    # before_action

    def set_article
      @article = current_user.articles.find_by(id: params[:id])
    end

    def check_article_owner
      @article = Article.find_by(id: params[:id])
      unless current_user.id == @article.user_id
        flash[:danger] = '不正な操作です。'
        redirect_to users_articles_path(page: params[:page])
      end
    end
    
    def set_dashboard
      params[:dashboard] ||= 'false'
      @dashboard = !(params[:dashboard] == 'false')
    end
  end
end
