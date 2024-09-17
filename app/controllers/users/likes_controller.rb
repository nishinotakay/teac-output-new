class Users::LikesController < ApplicationController
  before_action :set_article, only: %i[article_create article_destroy]
  before_action :set_post, only: %i[post_create post_destroy]
  before_action :set_tweet, only: %i[tweet_create tweet_destroy]
  before_action :authenticate_user!, only: %i[article_create article_destroy post_create post_destroy tweet_create tweet_destroy]

  def article_create
    @like = current_user.likes.new(like_params)
    @like.save
  end

  def article_destroy
    @like = current_user.likes.find_by(like_params)
    @like.destroy
  end

  def post_create
    @like = current_user.likes.new(post_like_params)
    @like.save
  end

  def post_destroy
    @like = current_user.likes.find_by(post_like_params)
    @like.destroy
  end

  def tweet_create
    @like = current_user.likes.new(tweet_like_params)
    @like.save
  end

  def tweet_destroy
    @like = current_user.likes.find_by(tweet_like_params)
    @like.destroy
  end

  private

  def set_article
    @article = Article.find(params[:article_id])
  end

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_tweet
    @tweet = Tweet.find(params[:tweet_id])
  end

  def like_params
    params.permit(:article_id)
  end

  def post_like_params
    params.permit(:post_id)
  end

  def tweet_like_params
    params.permit(:tweet_id)
  end
end