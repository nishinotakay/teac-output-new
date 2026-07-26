class Api::V1::Admin::PostsController < Api::V1::BaseController
  before_action :authenticate_admin!
  before_action :set_post, only: [:show, :update, :destroy]
  before_action :authorize_post_owner!, only: [:update, :destroy]

  # GET /api/v1/admin/posts
  def index
    posts = Post.includes(:user, :admin).order(created_at: :desc)
    render json: { posts: posts.map { |p| post_json(p) } }
  end

  # GET /api/v1/admin/posts/:id
  def show
    render json: { post: post_json(@post) }
  end

  # POST /api/v1/admin/posts
  def create
    post = @current_admin.posts.build(post_params)
    if post.save
      render json: { post: post_json(post) }, status: :created
    else
      render json: { errors: post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /api/v1/admin/posts/:id
  def update
    if @post.update(post_params)
      render json: { post: post_json(@post) }
    else
      render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/admin/posts/:id
  def destroy
    @post.destroy
    render json: { message: '削除しました' }
  end

  private

  def set_post
    @post = Post.find_by(id: params[:id])
    render_not_found('投稿') unless @post
  end

  def authorize_post_owner!
    if @post.admin_id.present? && @post.admin_id != @current_admin.id
      render json: { error: '権限がありません' }, status: :forbidden
    end
  end

  def post_params
    params.permit(:title, :body, :youtube_url)
  end

  def post_json(post)
    {
      id: post.id.to_s,
      title: post.title,
      body: post.body,
      youtubeUrl: post.youtube_url,
      userId: post.user_id&.to_s,
      adminId: post.admin_id&.to_s,
      posterName: (post.user&.name || post.admin&.name),
      createdAt: post.created_at.iso8601,
      updatedAt: post.updated_at.iso8601
    }
  end
end
