# frozen_string_literal: true

module Users
  class ArticlesController < Users::Base
    before_action :set_article, except: [:index, :new, :create]

    def index; end

    def show
    end

    def new
      @article = current_user.articles.new
    end

    def create
      @article = current_user.articles.new(article_params)
      if @article.save
        flash[:notice] = "記事を作成しました。"
        redirect_to users_article_url(@article)
      else
        flash.now[:alert] = "記事の作成に失敗しました。"
        render :new
      end
    end

    def edit
    end

    def update
      if @article.update(article_params)
        flash[:notice] = "記事を編集しました。"
        redirect_to users_article_url(@article)
      else
        flash.now[:alert] = "記事の編集に失敗しました。"
        render :edit
      end
    end

    def destroy
      flash[:notice] = "記事を削除しました。"
      @article.destroy
      redirect_to users_profile_url(current_user)
    end

    private

      def article_params
        params.require(:article).permit(:title, :sub_title, :content)
      end

    #before_action

      def set_article
        @article = current_user.articles.find(params[:id])
      end
  end
end
