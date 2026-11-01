class Api::V1::Users::PostsController < Api::V1::BaseController
  before_action :authenticate_user!
  before_action :set_post, only: [:show, :update, :destroy]

  # GET /api/v1/posts
  def index
    posts = @current_user.posts.order(created_at: :desc)
    render json: { posts: posts.map { |p| post_json(p) } }
  end

  # GET /api/v1/posts/:id
  def show
    render json: { post: post_json(@post) }
  end

  # POST /api/v1/posts
  def create
    post = @current_user.posts.build(post_params)
    if post.save
      render json: { post: post_json(post) }, status: :created
    else
      render json: { errors: post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /api/v1/posts/:id
  def update
    unless @post.user_id == @current_user.id
      return render json: { error: '権限がありません' }, status: :forbidden
    end

    if @post.update(post_params)
      render json: { post: post_json(@post) }
    else
      render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/posts/:id
  def destroy
    unless @post.user_id == @current_user.id
      return render json: { error: '権限がありません' }, status: :forbidden
    end

    @post.destroy
    render json: { message: '削除しました' }
  end

  private

  def set_post
    @post = Post.find_by(id: params[:id])
    render_not_found('投稿') unless @post
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
      createdAt: post.created_at.iso8601,
      updatedAt: post.updated_at.iso8601
    }
  end
end
