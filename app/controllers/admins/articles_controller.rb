module Admins
  class ArticlesController < Admins::Base
    protect_from_forgery
    before_action :set_article, except: %i[index new create image]
    before_action :set_dashboard, only: %i[show new create edit update destroy]

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
        @articles = Article.order(created_at: params[:order]).page(params[:page]).per(30)
      else
        (@paginate = filter.compact.present?)
        filter[:order] = params[:order]
        @articles = Article.sort_filter(filter).page(params[:page]).per(30)
      end
    end

    def show
      #@article = Article.find(params[:id])
    end

    def users_show
      @user = @article.user
    end

    def users_update
      if @article.update(article_params)
        flash[:notice] = '記事を編集しました。'
        redirect_to users_show_admins_article_url(@article, dashboard: params[:dashboard], page: params[:page])
      else
        flash.now[:alert] = '記事の編集に失敗しました。'
        render :edit
      end
    end

    def new
      @article = current_admin.articles.new
    end

    def create
      @article = current_admin.articles.new(article_params)
      if @article.save
        flash[:notice] = '記事を作成しました。'
        redirect_to admins_article_url(@article, dashboard: params[:dashboard], page: params[:page])
      else
        flash.now[:alert] = '記事の作成に失敗しました。'
        render :new
      end
    end

    def edit
      @show = params[:show].present?
    end

    def users_edit
      @show = params[:show].present?
      @user = @article.user
    end

    def update
      if @article.update(article_params)
        flash[:notice] = '記事を編集しました。'
        redirect_to admins_article_url(@article, dashboard: params[:dashboard], page: params[:page])
      else
        flash.now[:alert] = '記事の編集に失敗しました。'
        render :edit
      end
    end

    def destroy
      flash[:notice] = '記事を削除しました。'
      @article.destroy
      if @dashboard
        redirect_to admins_dash_boards_path(current_admin, page: params[:page])
      else
        redirect_to admins_articles_path(page: params[:page])
      end
    end

    def users_destroy
      flash[:notice] = '記事を削除しました。'
      @article.destroy
      redirect_to admins_articles_path(current_admin, page: params[:page])
    end

    def image
      admin = Admin.find(params[:admin_id])
      @article = admin.articles.new(params.permit(:image))
      render json: { name: @article.image.identifier, url: @article.image.url }
    end

    private

    def article_params
      params.require(:article).permit(:title, :sub_title, :content)
    end

    # before_action

    def set_article
      @article = Article.find(params[:id])
    end

    def set_dashboard
      params[:dashboard] ||= 'false'
      @dashboard = (params[:dashboard] != 'false')
    end
  end
end
