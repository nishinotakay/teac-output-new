class Api::V1::Users::ArticlesController < Api::V1::BaseController
  before_action :authenticate_user!
  before_action :set_article, only: [:show, :update, :destroy]
  before_action :reject_other_users_article, only: [:update, :destroy]

  # GET /api/v1/articles
  def index
    articles = Article.includes(:likes).order(created_at: :desc)
    render json: { articles: articles.map { |article| article_json(article) } }
  end

  # GET /api/v1/articles/:id
  def show
    render json: { article: article_json(@article) }
  end

  # POST /api/v1/articles
  def create
    article = @current_user.articles.build(article_params)
    if article.save
      render json: { article: article_json(article) }, status: :created
    else
      render json: { errors: article.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /api/v1/articles/:id
  def update
    if @article.update(article_params)
      render json: { article: article_json(@article) }
    else
      render json: { errors: @article.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/articles/:id
  def destroy
    @article.destroy
    render json: { message: '削除しました' }
  end

  private

  def set_article
    @article = Article.find_by(id: params[:id])
    render_not_found('記事') unless @article
  end

  def reject_other_users_article
    return if @article.user_id == @current_user.id

    render json: { error: '権限がありません' }, status: :forbidden
  end

  def article_params
    params.permit(:title, :sub_title, :content, :article_type)
  end

  def article_json(article)
    {
      id: article.id.to_s,
      title: article.title,
      subTitle: article.sub_title,
      content: article.content,
      articleType: article.article_type,
      image: article.image,
      userId: article.user_id&.to_s,
      adminId: article.admin_id&.to_s,
      likesCount: article.likes.size,
      likedByCurrentUser: article.likes.any? { |like| like.user_id == @current_user.id },
      createdAt: article.created_at.iso8601,
      updatedAt: article.updated_at.iso8601
    }
  end
end
