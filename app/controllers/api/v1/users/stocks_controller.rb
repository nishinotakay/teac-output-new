class Api::V1::Users::StocksController < Api::V1::BaseController
  before_action :authenticate_user!

  # GET /api/v1/stocks
  def index
    stocks = @current_user.stocks.includes(:article)
    render json: { stocks: stocks.map { |s| stock_json(s) } }
  end

  # POST /api/v1/stocks
  def create
    article = Article.find_by(id: params[:article_id])
    return render_not_found('記事') unless article

    stock = @current_user.stocks.find_or_initialize_by(article_id: article.id)
    if stock.new_record?
      stock.save
      render json: { stock: stock_json(stock) }, status: :created
    else
      render json: { error: 'すでにストック済みです' }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/stocks/:id
  def destroy
    stock = @current_user.stocks.find_by(id: params[:id])
    return render_not_found('ストック') unless stock

    stock.destroy
    render json: { message: '削除しました' }
  end

  private

  def stock_json(stock)
    {
      id: stock.id.to_s,
      articleId: stock.article_id.to_s,
      userId: stock.user_id.to_s,
      createdAt: stock.created_at.iso8601
    }
  end
end
