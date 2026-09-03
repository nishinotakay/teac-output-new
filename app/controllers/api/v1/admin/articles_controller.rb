class Api::V1::Admin::ArticlesController < Api::V1::BaseController
  include IsoDateParams

  before_action :authenticate_admin!
  before_action :set_article, only: %i[show update destroy]
  before_action :validate_date_params, only: :index

  # GET /api/v1/admin/articles
  # Article.paginated_and_sort_filter は使わない: 未指定の条件を付けない
  # （本番は日付既定値で未来の記事が、sub_title LIKE '%%' で sub_title が NULL の記事が消える）
  # TODO: ページング（本番は30件/ページ）と e-learning 除外は仕様確認後に追加する
  def index
    direction = order_direction
    articles = Article.includes(:user, :admin)
      .title_like(params[:title])
      .sub_title_like(params[:subtitle])
      .content_like(params[:content])
      .author_name_like(params[:author])
      .created_on_or_after(parse_iso_date(params[:start]))
      .created_on_or_before(parse_iso_date(params[:finish]))
      .order(created_at: direction, id: direction)
    render json: { articles: articles.map { |article| article_json(article) } }
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

  def validate_date_params
    invalid_key = invalid_iso_date_param_key
    render_bad_request("#{invalid_key} は YYYY-MM-DD 形式で指定してください") if invalid_key
  end

  def order_direction
    params[:order].to_s.casecmp?('ASC') ? :asc : :desc
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
      authorName:  article.user&.name || article.admin&.name,
      createdAt:   article.created_at.iso8601,
      updatedAt:   article.updated_at.iso8601
    }
  end
end
