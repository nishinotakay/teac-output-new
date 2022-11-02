module Users
  class PostsController < Users::Base
    # Userがログインしていないと、投稿を作成できない
    before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
    before_action :set_post, only: %i[ show edit update destroy ]
    # GET /posts or /posts.json
    def index
      @posts = current_user.posts.all.search(params[:search])
    end

    # GET /posts/1 or /posts/1.json
    def show
    end

    # GET /posts/new
    def new
      @post = current_user.posts.new
    end

    # GET /posts/1/edit
    def edit
    end

    # POST /posts or /posts.json
    def create
      @post = current_user.posts.new(post_params)
        #追記した部分ここから
        url = params[:post][:youtube_url]
        url = url.last(11)
        @post.youtube_url = url
        #ここまで
      if @post.save
        redirect_to users_post_path(@post), flash: {success: "動画投稿完了致しました"}
      else
        flash.now[:danger] = '動画投稿出来ませんでした。'  # 4/25訂正
        render :new
      end
    end

    # PATCH/PUT /posts/1 or /posts/1.json
    def update
      respond_to do |format|
        if @post.update(post_params)
          format.html { redirect_to @post, notice: "Post was successfully updated." }
          format.json { render :show, status: :ok, location: @post }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @post.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /posts/1 or /posts/1.json
    def destroy
      if @post.destroy!
        redirect_to users_posts_path, flash: {warning: "動画を削除しました。"}
      else
        redirect_to :index
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.

      def set_post
        @post = current_user.posts.find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def post_params
        params.require(:post).permit(:title, :body, :youtube_url)
      end
  end
end