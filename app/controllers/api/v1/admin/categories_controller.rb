class Api::V1::Admin::CategoriesController < Api::V1::BaseController
  before_action :authenticate_admin!

  def index
    course = Course.find_by(id: params[:course_id])
    return render_not_found('コース') unless course

    categories = course.categories.order(:id)

    render json: {
      course: {
        id: course.id.to_s,
        name: course.name
      },
      categories: categories.map do |category|
        {
          id: category.id.to_s,
          name: category.name
        }
      end
    }
  end

  def update
    course = Course.find_by(id: params[:course_id])
    return render_not_found('コース') unless course
  
    category = course.categories.find_by(id: params[:id])
    return render_not_found('カテゴリー') unless category
  
    if category.update(category_params)
      render json: {
        category: {
          id: category.id.to_s,
          name: category.name
        }
      }
    else
      render json: {
        errors: category.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def create
    course = Course.find_by(id: params[:course_id])
    return render_not_found('コース') unless course

    category = course.categories.new(category_params)
    category.tenant = course.tenant # 追加
    if category.save
      render json: {
        category: {
          id: category.id.to_s,
          name: category.name
        }
      }, status: :created
    else
      render json: {
        errors: category.errors.full_messages
      }, status: :unprocessable_entity
    end
  end


  def destroy
    course = Course.find_by(id: params[:course_id])
    return render_not_found('コース') unless course

    category = course.categories.find_by(id: params[:id])
    return render_not_found('カテゴリー') unless category

    if category.destroy
      head :no_content
    else
      render json: { errors: category.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def articles
    course = Course.find_by(id: params[:course_id])
    return render_not_found('コース') unless course
  
    category = course.categories.find_by(id: params[:id])
    return render_not_found('カテゴリー') unless category
  
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
        id: course.id.to_s,
        name: course.name
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
    }
  end

  private
  def category_params
    params.permit(:name)
  end
end
