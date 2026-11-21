class Api::V1::Admin::VideoCommentsController < Api::V1::BaseController
  before_action :authenticate_admin!
  before_action :set_post
  before_action :set_own_comment, only: :update
  before_action :set_deletable_comment, only: :destroy

  # GET /api/v1/admin/posts/:post_id/comments
  def index
    comments = @post.video_comments.top_level.includes(:user, :admin, replies: %i[user admin])
      .order(created_at: :desc, id: :desc)
    render json: { comments: comments.map { |comment| comment_json(comment, with_replies: true) } }
  end

  # POST /api/v1/admin/posts/:post_id/comments
  def create
    parent = find_parent
    return if performed?

    comment = @post.video_comments.build(content: params[:content], parent: parent, admin: @current_admin)
    if comment.save
      render json: { comment: comment_json(comment, with_replies: true) }, status: :created
    else
      render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /api/v1/admin/posts/:post_id/comments/:id
  def update
    if @comment.update(content: params[:content])
      render json: { comment: comment_json(@comment, with_replies: @comment.parent_id.nil?) }
    else
      render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/admin/posts/:post_id/comments/:id
  def destroy
    @comment.destroy
    head :no_content
  end

  private

  def set_post
    @post = Post.find_by(id: params[:post_id])
    render_not_found('動画') unless @post
  end

  def set_own_comment
    @comment = @post.video_comments.find_by(id: params[:id], admin_id: @current_admin.id)
    render_not_found('コメント') unless @comment
  end

  def set_deletable_comment
    @comment = @post.video_comments.find_by(id: params[:id])
    render_not_found('コメント') unless @comment
  end

  def find_parent
    return nil if params[:parent_id].blank?

    parent = @post.video_comments.find_by(id: params[:parent_id])
    render_not_found('コメント') unless parent
    parent
  end

  def comment_json(comment, with_replies: false)
    json = {
      id:         comment.id.to_s,
      postId:     comment.post_id.to_s,
      parentId:   comment.parent_id&.to_s,
      content:    comment.content,
      authorType: comment.admin_id ? 'admin' : 'user',
      authorId:   (comment.admin_id || comment.user_id).to_s,
      authorName: (comment.user || comment.admin)&.name.to_s,
      isMine:     comment.admin_id == @current_admin.id,
      canDelete:  true,
      createdAt:  comment.created_at.iso8601,
      updatedAt:  comment.updated_at.iso8601
    }
    json[:replies] = replies_json(comment) if with_replies
    json
  end

  def replies_json(comment)
    comment.replies.sort_by { |reply| [reply.created_at, reply.id] }.map { |reply| comment_json(reply) }
  end
end
