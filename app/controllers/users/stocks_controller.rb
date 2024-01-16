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
    @stock_article = Stock.get_stock_article(current_user)
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
