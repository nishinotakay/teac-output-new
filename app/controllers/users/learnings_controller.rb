module Users
  class LearningsController < Users::Base
    def index
      @e_learning_articles = Article.where(article_type: 'e-learning').page(params[:page]).per(10)
    end

    def show
      @article = Article.find(params[:id])
    end

    def update

    end
  end
end
