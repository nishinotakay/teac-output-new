module Admins
  class PostsController < Admins::Base
    before_action :authenticate_admin!, only: %i[show index new create edit update destroy]
    before_action :set_post, only: %i[show edit update destroy]
    before_action :prevent_url, only: %i[edit update destroy]

    def index
      @posts = Post.filtered_and_ordered_posts(params, params[:page], 30)

      respond_to do |format|
        format.html
        format.json { render json: @posts }
      end
    end

    def show
      @post = Post.find(params[:id])

      respond_to do |format|
        format.html
        format.json { render json: @post }
      end
    end

    def new
      @post = current_admin.posts.new
    end

    def edit
      respond_to do |format|
        format.html
        format.json { render json: @post }
      end
    end

    def create
      @post = current_admin.posts.new(post_params)
      url = params[:post][:youtube_url].last(11)
      @post.youtube_url = url
      if @post.save
        redirect_to admins_post_path(@post), flash: { success: '動画を投稿しました' }
      else
        render :new
      end
    end

    def update
      url = params[:post][:youtube_url].last(11)
      @post.youtube_url = url
      if @post.update(post_params)
        redirect_to admins_posts_path(@post), flash: { success: '動画情報を更新しました' }
      else
        render :edit
      end
    end

    def destroy
      if @post.destroy
        redirect_to admins_posts_path, flash: { warning: '動画を削除しました。' }
      else
        redirect_to :index
      end
    end

    private

      def set_post
        @post = Post.find(params[:id])
      end

      def post_params
        params.require(:post).permit(:title, :body, :youtube_url)
      end

      def prevent_url
        unless current_admin.present?
          redirect_to root_path, alert: '権限がありません。'
        end
      end
  end
end
