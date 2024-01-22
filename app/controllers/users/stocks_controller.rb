module Users
  class Users::StocksController < Users::Base
    before_action :set_article, only: %i[create destroy]

  def create
    @stock = current_user.stocks.create(stock_params)
  end

  def destroy
    @stock = Stock.find_by(stock_params)
    @stock.destroy
  end

  def index
    filter = {
      author: params[:author],
      title: params[:title],
      subtitle: params[:subtitle],
      content: params[:content],
      start: params[:start],
      finish: params[:finish],
      order: params[:order] ||= 'DESC'
    }

    @stocks = Article.stock_paginated_and_sort_filter(filter,current_user).page(params[:page]).per(30)
    respond_to do |format|
      format.html
      format.json { render json: @stocks }
    end

  end

  private

  def set_article
    @article = Article.find(params[:article_id])
  end

  def stock_params
    params.permit(:article_id,:id)
  end

  end
end
