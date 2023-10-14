module Users
  class PostsController < Users::Base
    before_action :authenticate_user!, only: %i[show index new create edit update destroy]
    before_action :set_post, only: %i[show edit update destroy]
    before_action :prevent_url, only: %i[edit update destroy]

    def index
      @posts = Post.filtered_and_ordered_posts(params, params[:page], 30)
    end

    def show; end

    def new
      @post = current_user.posts.new
    end

    def edit; end

    def create
      @post = current_user.posts.new(post_params)
      url = params[:post][:youtube_url].last(11)
      @post.youtube_url = url
      if @post.save
        redirect_to users_post_path(@post), flash: { success: '動画投稿完了致しました' }
      else
        render :new
      end
    end

    def update
      url = params[:post][:youtube_url].last(11)
      @post.youtube_url = url
      if @post.update(post_params)
        redirect_to users_posts_path(@post), flash: { success: '動画編集完了致しました' }
      else
        render :edit
      end
    end

    def destroy
      if @post.destroy!
        redirect_to users_posts_path, flash: { warning: '動画を削除しました。' }
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
        @post = current_user.posts.find(params[:id])
        if @post.user_id != current_user.id
          redirect_to root_path
        end
      end
  end
end
