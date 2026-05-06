# ユーザー向けいいねコントローラ: ユーザーが記事・動画投稿へのいいねを追加・削除するアクションを提供する

class Users::LikesController < ApplicationController
  before_action :set_article, only: %i[article_create article_destroy]
  before_action :set_post, only: %i[post_create post_destroy]
  before_action :authenticate_user!, only: %i[article_create article_destroy]

  # 記事へのいいねを追加する
  def article_create
    @like = current_user.likes.new(like_params)
    @like.save
  end

  # 記事へのいいねを削除する
  def article_destroy
    @like = current_user.likes.find_by(like_params)
    @like.destroy
  end

  # 動画投稿へのいいねを追加する
  def post_create
    @like = current_user.likes.new(post_like_params)
    @like.save
  end

  # 動画投稿へのいいねを削除する
  def post_destroy
    @like = current_user.likes.find_by(post_like_params)
    @like.destroy
  end

  private

  def set_article
    @article = Article.find(params[:article_id])
  end

  def set_post
    @post = Post.find(params[:post_id])
  end

  def like_params
    params.permit(:article_id)
  end

  def post_like_params
    params.permit(:post_id)
  end

end
