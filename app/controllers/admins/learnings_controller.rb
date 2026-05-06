# 管理者向けe-learningコントローラ: 管理者がe-learning記事一覧を閲覧し、受講完了を記録するアクションを提供する

module Admins
  class LearningsController < Admins::Base
    before_action :authenticate_admin!

    # e-learning記事の一覧をページネーション付きで表示する
    def index
      @e_learning_articles = Article.where(article_type: 'e-learning').page(params[:page]).per(10)
    end

    # e-learning記事の詳細を表示する
    def show
      @learning_article = Article.find(params[:id])
    end

    # e-learning記事の受講完了を記録する
    def create
      article = Article.find(params[:article_id])
      learning = current_admin.learning_status.find_or_initialize_by(learned_article_id: article.id)
      if learning.completed
        redirect_to admins_learnings_path
      else
        learning.update(completed: true)
        redirect_to admins_learnings_path
      end
    end
  end
end
