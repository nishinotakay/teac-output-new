module Users
  class ArticlesController < Users::Base
    before_action :set_article, only: %i[ show edit update destroy ]

    def index
      @users = User.all
      @articles = Article.all
    end
    
    def new
      @article = current_user.articles.new
    end
    
    def edit
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
    
    def update
      if @article.update(article_params)
        flash[:notice] = "記事を編集しました。"
      else
        flash[:alert] = "記事の編集に失敗しました。"
      end
      redirect_to users_article_url(@article)
    end
    
    def destroy
      @article.delete
      flash[:notice] = "記事「#{@article.title}」を削除しました。"
      redirect_to users_articles_url
    end

    def show
      @article = Article.find(params[:id])
    
    end
    
    def image
      @article = current_user.articles.new(params.permit(:image))
      # @article = current_user.articles.new(image: params[:image])
      render json: { name: @article.image.identifier, url: @article.image.url }
      # respond_to do |format|
        # format.json { render json: { name: @article.image.identifier, url: @article.image.url } }
      # end
    end
    
  end
end

private

  def set_article
    @article = current_user.articles.find(params[:id])
  end

  def article_params
    params.require(:article).permit(:title, :sub_title, :content, :user_id)
  end