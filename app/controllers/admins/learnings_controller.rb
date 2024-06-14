module Admins
  class LearningsController < Admins::Base
    before_action :authenticate_admin!
    before_action :set_learning, only: [:show, :edit, :update, :destroy]

    def index
      @e_learning_articles = Article.where(article_type: 'e-learning').page(params[:page]).per(10)
    end

    def show
      @learning_article = Article.find(params[:id])
      @learning = current_admin.learning_status.find_or_initialize_by(learned_article_id: @learning_article.id)
    end

    def edit
      @learning = Article.find(params[:id])
    end

    def update
      @learning_article = Article.find(params[:id])

      if @learning_article.update(article_params)
        redirect_to admins_learning_path(@learning_article), notice: '記事が更新されました'
      else
        render :edit, alert: '記事の更新に失敗しました'
      end
    end

    def destroy
      @learning_article = Article.find(params[:id])
      @learning_article.destroy
      redirect_to admins_learnings_path, notice: "記事を削除しました"
    end

    def create
      Rails.logger.debug "params[:learning]: #{params[:learning]}"
      article_id = params.dig(:learning, :article_id)
      Rails.logger.debug "article_id: #{article_id}"

      article = Article.find_by(id: article_id)

      if article.nil?
        Rails.logger.debug "Article not found for id: #{article_id}"
        redirect_to some_error_path, alert: "Article not found" and return
      end

      if current_admin.nil?
        Rails.logger.debug "current_admin is nil"
        redirect_to some_login_path, alert: "You need to sign in before continuing." and return
      end

      learning = current_admin.learning_status.find_or_initialize_by(learned_article_id: article.id)

      if learning.completed
        redirect_to users_learnings_path
      else
        # 学習ステータスを更新するためのロジックをここに追加
      end
    end

    private

    def set_learning
      @learning = Article.find(params[:id])
    end

    def article_params
      params.require(:article).permit(:title, :content, :article_type)
    end
  end
end
