class Api::V1::Admin::CategoryArticlesController < Api::V1::BaseController
  before_action :authenticate_admin!

  def create
    category = Category.find(params[:category_id])
    article_ids = category_articles_params[:articleIds]
    unless article_ids.is_a?(Array) && article_ids.present? &&
           article_ids.all? { |id| id.is_a?(String) && id.match?(/\A[0-9]+\z/) }
      return render_bad_request('articleIdsには記事IDの配列を指定してください')
    end

    ActiveRecord::Base.transaction do
      article_ids.each do |article_id|
        # 1つでも失敗して例外が出ると、すべてロールバックされる
        article = Article.find(article_id)
        category.article_categories.create!(article: article)
      end
    end

    # このカテゴリーに紐付いている記事
    linked_articles = category.articles
                              .includes(:user, :admin)
                              .order(:id)

    # このカテゴリーにまだ紐付いていない記事
    available_articles = Article
                         .where.not(id: category.articles.select(:id))
                         .includes(:user, :admin)
                         .order(:id)
    render json: {
      course: {
        id: category.course.id.to_s,
        name: category.course.name
      },
      category: {
        id: category.id.to_s,
        name: category.name
      },
      linkedArticles: linked_articles.map do |article|
        {
          id: article.id.to_s,
          title: article.title,
          author: article.poster_name.to_s,
          content: article.content.to_s,
          tenant_id: article.tenant_id
        }
      end,
      availableArticles: available_articles.map do |article|
        {
          id: article.id.to_s,
          title: article.title,
          author: article.poster_name.to_s,
          content: article.content.to_s,
          tenant_id: article.tenant_id
        }
      end
    }, status: :created
  rescue ActiveRecord::RecordNotFound
    render_not_found('カテゴリーまたは記事')
  rescue ActiveRecord::RecordInvalid => error
    render json: { errors: error.record.errors.full_messages }, status: :unprocessable_entity
  rescue ActiveRecord::RecordNotUnique
    render json: { errors: ['この記事はすでにカテゴリーに紐付いています'] }, status: :unprocessable_entity
  end

  def destroy
    category = Category.find(params[:category_id])

    # ログイン中のテナントで扱える記事を探す
    article = Article.find(params[:id])

    # このカテゴリーと記事の「紐付け」だけを探す
    article_category = category.article_categories.find_by!(
      article_id: article.id
    )

    article_category.destroy!

    head :no_content
  rescue ActiveRecord::RecordNotFound
    render_not_found('カテゴリー・記事または紐付け')
  end

  private

  def category_articles_params
    params.permit(articleIds: [])
  end
end
