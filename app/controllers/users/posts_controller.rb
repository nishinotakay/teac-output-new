module Users
  class PostsController < Users::Base
    before_action :authenticate_user!, only: %i[show index new create edit update destroy index_user]
    before_action :set_post, only: %i[show edit update destroy]
    before_action :prevent_url, only: %i[edit update destroy]
    skip_before_action :authenticate_user!, only: %i[show], if: :admin_signed_in?

    def index
      @posts = Post.includes(:likes,:post_comments).filtered_and_ordered_posts(params, params[:page], 30)

      respond_to do |format|
        format.html
        format.json { render json: @posts }
      end
    end

    def show
      @post_comments = @post.post_comments.includes(:user).order(created_at: :desc)
      @post_comment = current_user.post_comments.new unless current_admin.present?

      respond_to do |format|
        format.html
        format.json { render json: @post }
      end
    end

    def new
      @post = current_user.posts.new
    end

    def edit
      respond_to do |format|
        format.html
        format.json { render json: @post }
      end
    end

    def create
      @post = current_user.posts.new(post_params)
      url = params[:post][:youtube_url].last(11)
      @post.youtube_url = url
      if @post.save
        redirect_to users_post_path(@post), flash: { success: '動画を投稿しました' }
      else
        render :new
      end
    end

    def update
      url = params[:post][:youtube_url].last(11)
      @post.youtube_url = url
      if @post.update(post_params)
        redirect_to users_post_path(@post), flash: { success: '動画情報を更新しました' }
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

    def index_user
      @user = User.includes(:posts).find(params[:user_id])
      @posts = @user.posts.filtered_and_ordered_posts(params, params[:page], 30)
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
