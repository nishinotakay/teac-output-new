# ユーザー向けe-learningコントローラ: ユーザーがe-learning記事一覧を閲覧し、受講完了を記録するアクションを提供する

module Users
  class LearningsController < Users::Base
    before_action :authenticate_user!

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
      learning = current_user.learning_status.find_or_initialize_by(learned_article_id: article.id)
      if learning.completed
        redirect_to users_learnings_path
      else
        learning.update(completed: true)
        redirect_to users_learnings_path
      end
    end
  end
end
