class Api::V1::Admin::ArticlesController < Api::V1::BaseController
  include IsoDateParams

  # 絞り込みパラメータが不正なときの例外。rescue_from で 400 にする
  class InvalidOrderParam < ArgumentError
    def initialize(message = 'order は ASC または DESC で指定してください')
      super
    end
  end

  class InvalidKeywordParam < ArgumentError
    def initialize(key)
      super("#{key} は文字列で指定してください")
    end
  end

  ORDER_DIRECTIONS = %w[asc desc].freeze
  KEYWORD_PARAM_KEYS = %i[title subtitle content author].freeze

  before_action :authenticate_admin!
  before_action :set_article, only: %i[show update destroy]
  before_action :set_filter_params, only: :index

  rescue_from IsoDateParams::InvalidIsoDateParam, InvalidOrderParam, InvalidKeywordParam do |error|
    render_bad_request(error.message)
  end

  # GET /api/v1/admin/articles
  # paginated_and_sort_filter は使わない（未指定の条件を付けないため。背景は PR #290）
  # TODO: ページングは次のPRで対応する（PR #290 レビュー③）。e-learning 除外は仕様確認後に追加する
  def index
    render json: { articles: filtered_articles.map { |article| article_json(article) } }
  end

  # GET /api/v1/admin/articles/:id
  def show
    render json: { article: article_json(@article) }
  end

  # POST /api/v1/admin/articles
  def create
    article = @current_admin.articles.build(article_params)
    if article.save
      render json: { article: article_json(article) }, status: :created
    else
      render json: { errors: article.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /api/v1/admin/articles/:id
  def update
    if @article.update(article_params)
      render json: { article: article_json(@article) }
    else
      render json: { errors: @article.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/admin/articles/:id
  def destroy
    @article.destroy
    render json: { message: '削除しました' }
  end

  private

  # 絞り込み・並び順のパラメータを検証して保持する。不正値は例外になり rescue_from が 400 を返す
  def set_filter_params
    @filter_start_date  = iso_date_param(:start)
    @filter_finish_date = iso_date_param(:finish)
    @order_direction    = order_direction_param
    @keywords           = KEYWORD_PARAM_KEYS.index_with { |key| keyword_param(key) }
  end

  # 未指定（blank）は :desc。ASC / DESC（大文字小文字は区別しない）以外は InvalidOrderParam
  def order_direction_param
    value = params[:order]
    return :desc if value.blank?
    raise InvalidOrderParam unless value.kind_of?(String) && ORDER_DIRECTIONS.include?(value.downcase)

    value.downcase.to_sym
  end

  # 未指定（blank）は nil。文字列以外（配列・ハッシュ）は InvalidKeywordParam
  def keyword_param(key)
    value = params[key]
    return nil if value.blank?
    raise InvalidKeywordParam, key unless value.kind_of?(String)

    value
  end

  def filtered_articles
    Article.includes(:user, :admin)
      .title_like(@keywords[:title])
      .sub_title_like(@keywords[:subtitle])
      .content_like(@keywords[:content])
      .author_name_like(@keywords[:author])
      .created_on_or_after(@filter_start_date)
      .created_on_or_before(@filter_finish_date)
      .order(created_at: @order_direction, id: @order_direction)
  end

  def set_article
    @article = Article.find_by(id: params[:id])
    render_not_found('記事') unless @article
  end

  def article_params
    params.permit(:title, :sub_title, :content, :article_type)
  end

  def article_json(article)
    {
      id:          article.id.to_s,
      title:       article.title,
      subTitle:    article.sub_title,
      content:     article.content,
      articleType: article.article_type,
      image:       article.image,
      userId:      article.user_id&.to_s,
      adminId:     article.admin_id&.to_s,
      posterName:  article.poster_name,
      createdAt:   article.created_at.iso8601,
      updatedAt:   article.updated_at.iso8601
    }
  end
end
