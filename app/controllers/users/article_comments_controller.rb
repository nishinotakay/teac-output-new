module Users
  class ArticleCommentsController < Users::Base
    def create
      params[:dashboard] ||= 'false'
      @dashboard = !(params[:dashboard] == 'false')
      @article = Article.find(params[:article_id])
      @article_comment = @article.article_comments.new(article_comment_params.merge(user_id: current_user.id))
      if @article_comment.save
        flash[:notice] = 'コメントを投稿しました。'
        redirect_to users_article_url(@article_comment.article, dashboard: params[:dashboard], page: params[:page])
      else
        flash[:alert] = @article_comment.errors.full_messages.join(', ')
        redirect_to users_article_url(@article_comment.article, dashboard: params[:dashboard], page: params[:page]), alert: @article_comment.errors.full_messages.join(', ')
      end
    end

    def update
      params[:dashboard] ||= 'false'
      @dashboard = !(params[:dashboard] == 'false')
      @article = Article.find(params[:article_id])
      @article_comment = current_user.article_comments.find(params[:id])
      if @article_comment.update(article_comment_update_params)
        flash[:notice] = 'コメントを更新しました。'
      else
        flash[:alert] = @article_comment.errors.full_messages.join(', ')
      end
      redirect_to users_article_path(@article.id, dashboard: params[:dashboard], page: params[:page])
    end

    def destroy
      params[:dashboard] ||= 'false'
      @dashboard = !(params[:dashboard] == 'false')
      @article = Article.find(params[:article_id])
      @article_comment = current_user.article_comments.find(params[:id])
      if @article_comment.destroy
        redirect_to users_article_url(@article, dashboard: params[:dashboard], page: params[:page]), notice: 'コメント削除に成功しました。'
      else
        redirect_to users_article_url(@article, dashboard: params[:dashboard]), notice: 'コメント削除に失敗しました。'
      end
    end

    private

    def article_comment_params
      params.require(:article_comment).permit(:article_comment_content, :article_id)
    end

    def article_comment_update_params
      params.require(:article_comment).permit(:article_comment_content)
    end
  end
end
