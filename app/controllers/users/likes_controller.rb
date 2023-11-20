class Users::LikesController < ApplicationController
  before_action :set_article, only: %i[article_create article_destroy]  

  def article_create
    @like = current_user.likes.new(like_params)
    @like.save
  end

  def article_destroy
    @like = current_user.likes.find_by(like_params)
    @like.destroy
  end

  private

  def set_article
    @article = Article.find(params[:article_id])
  end

  def like_params
    params.permit(:article_id)
  end

end
