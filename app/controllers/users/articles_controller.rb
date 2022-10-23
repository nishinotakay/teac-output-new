# frozen_string_literal: true

module Users
  class ArticlesController < Users::Base
    protect_from_forgery
    before_action :set_article, except: %i[index show new create image]

    def index
      @users = User.all
      @articles = Article.all.order(updated_at: 'DESC')
    end

    def show
      @article = Article.find(params[:id])
      @dashboard = params[:dashboard] == "false" ? false : true
    end

    def new
      @article = current_user.articles.new
    end

    def create
      @article = current_user.articles.new(article_params)
      if @article.save
        flash[:notice] = 'メモを作成しました。'
        redirect_to users_article_url(@article)
      else
        flash.now[:alert] = 'メモの作成に失敗しました。'
        render :new
      end
    end

    def edit
    end

    def update
      if @article.update(article_params)
        flash[:notice] = 'メモを編集しました。'
        redirect_to users_article_url(@article)
      else
        flash.now[:alert] = 'メモの編集に失敗しました。'
        render :edit
      end
    end

    def destroy
      flash[:notice] = 'メモを削除しました。'
      @article.destroy
      dashboard = params[:dashboard] == "false" ? false : true
      if dashboard
        redirect_to users_dash_boards_path(current_user)
      else
        redirect_to users_articles_path
      end
    end

    def image
      user = User.find(params[:user_id])
      @article = user.articles.new(params.permit(:image))
      render json: { name: @article.image.identifier, url: @article.image.url }
    end

    private

    def article_params
      params.require(:article).permit(:title, :sub_title, :content)
    end

    # before_action

    def set_article
      @article = current_user.articles.find(params[:id])
    end
  end
end
