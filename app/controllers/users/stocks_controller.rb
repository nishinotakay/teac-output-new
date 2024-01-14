class Users::StocksController < ApplicationController

  def create
    @article = Article.find(params[:article_id])
    @stock = current_user.stocks.create(article_id: params[:article_id])
  end

  def destroy
    @article = Article.find(params[:article_id])
    @stock = Stock.find_by(
      article_id: params[:article_id],
      user_id: current_user.id
    )
    @stock.destroy
  end

  def index
    @stocks = Stock.where(user_id: current_user.id)
  end
end
