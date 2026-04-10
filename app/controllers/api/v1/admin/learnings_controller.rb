class Api::V1::Admin::LearningsController < Api::V1::BaseController
  before_action :authenticate_admin!

  # GET /api/v1/admin/learnings
  def index
    learnings = Learning.includes(:learned_article).order(created_at: :desc)
    render json: { learnings: learnings.map { |l| learning_json(l) } }
  end

  # POST /api/v1/admin/learnings
  def create
    article = Article.find_by(id: params[:article_id])
    return render_not_found('記事') unless article

    learning = Learning.find_or_initialize_by(
      admin_id: @current_admin.id,
      learned_article_id: article.id
    )
    learning.completed = params[:completed] || false

    if learning.save
      render json: { learning: learning_json(learning) }, status: :created
    else
      render json: { errors: learning.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def learning_json(learning)
    {
      id: learning.id.to_s,
      articleId: learning.learned_article_id.to_s,
      adminId: learning.admin_id&.to_s,
      learnerId: learning.learner_id&.to_s,
      completed: learning.completed,
      createdAt: learning.created_at.iso8601
    }
  end
end
