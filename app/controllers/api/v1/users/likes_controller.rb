class Api::V1::Users::LikesController < Api::V1::BaseController
  before_action :authenticate_user!

  # POST /api/v1/articles/:article_id/likes
  def article_create
    article = Article.find_by(id: params[:article_id])
    return render_not_found('記事') unless article

    like = @current_user.likes.find_or_initialize_by(article_id: article.id)
    if like.new_record?
      like.save
      render json: { liked: true }, status: :created
    else
      render json: { error: 'すでにいいね済みです' }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/articles/:article_id/likes
  def article_destroy
    like = @current_user.likes.find_by(article_id: params[:article_id])
    return render_not_found('いいね') unless like

    like.destroy
    render json: { liked: false }
  end

  # POST /api/v1/posts/:post_id/likes
  def post_create
    post = Post.find_by(id: params[:post_id])
    return render_not_found('投稿') unless post

    like = @current_user.likes.find_or_initialize_by(post_id: post.id)
    if like.new_record?
      like.save
      render json: { liked: true }, status: :created
    else
      render json: { error: 'すでにいいね済みです' }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/posts/:post_id/likes
  def post_destroy
    like = @current_user.likes.find_by(post_id: params[:post_id])
    return render_not_found('いいね') unless like

    like.destroy
    render json: { liked: false }
  end
end
