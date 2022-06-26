# frozen_string_literal: true

module Users
  class ArticlesController < Users::Base
    def index
      @articles = current_user.articles.all
    end

    def new
      # count = 0
      # if count <= 1
      #   count += 1
      #   redirect_to new_users_article_path(count)
      # end
      @article = current_user.articles.new

    end

    def create      
      @article = current_user.articles.new(article_params)      
      @article.save      
      # @article.update_attributes(article_params)
      flash[:notice] = '投稿しました' 
      redirect_to users_article_path(id: @article.id)
    end

    def show
      @article = Article.find(params[:id])  
    end

    def edit
      @article = Article.find(params[:id])  
    end

    def update
      @article = Article.find(params[:id])
      if @article.update(article_params)
      # if @article.update_attributes(article_params)
        redirect_to users_article_path(id: @article.id)
        flash[:success] = '情報を更新しました'
      elsif @article.errors.present?
        flash[:danger] = "更新に失敗しました"
        # flash[:danger] = "更新に失敗しました<br>" + @article.errors.full_messages.join("<br>")
        render :edit
        # redirect_to user_path(@user, date: @management.worked_on.beginning_of_month)
      end 
    end

    def destroy
      @article = Article.find(params[:id])
      @article.destroy
      flash[:danger] = "'#{@article.title}'を削除しました"
      redirect_to users_articles_path
    end

  end
end

private

  def article_params
    params.permit(:title, :sub_title, :content, :user_id)
  end

  # def article_params
  #   params.require(:user).permit(:name, :email, :password, :password_confirmation)
  # end
