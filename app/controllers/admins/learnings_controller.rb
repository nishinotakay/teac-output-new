module Admins
  class LearningsController < Admins::Base
    before_action :authenticate_admin!

    def index
      @e_learning_articles = Article.where(article_type: 'e-learning').page(params[:page]).per(10)
    end

    def show
      @learning_article = Article.find(params[:id])
    end

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
