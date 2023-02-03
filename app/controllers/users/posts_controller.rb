module Users
  class PostsController < Users::Base
    # Userがログインしていないと、投稿を作成・編集・削除できない
    before_action :authenticate_user!, only: [:show, :index, :new, :create, :edit, :update, :destroy]
    before_action :set_post, only: %i[ show edit edit_1 update update_1 destroy ]
    # 投稿したユーザーと現在のユーザーのidが違えばトップページに飛ばす
    before_action :prevent_url, only: [:edit, :update, :destroy]

    # 投稿動画一覧ページ
    def index
      # ログインしていなかった場合は401ページを表示して終了（※ 401用のテンプレートファイルを作っていないと動きません）
      @posts = Post.all.search(params[:search]).page(params[:page]).per(30)
    end
    
    # GET /posts/1 or /posts/1.json
    def show
    end

    # 新規投稿ページ
    def new
      @post = current_user.posts.new
    end

    # 投稿動画編集ページ
    def edit
    end

    # 全ユーザー詳細ページ内から自分の投稿動画編集ページ
    def edit_1
    end

    # 投稿動画作成
    def create
      @post = current_user.posts.new(post_params)
      url = params[:post][:youtube_url].last(11)
      @post.youtube_url = url
      if @post.save
        redirect_to users_post_path(@post), flash: {success: "動画投稿完了致しました"}
      else
        flash.now[:danger] = '動画投稿出来ませんでした。'  # 4/25訂正
        render :new
      end
    end

    # 投稿動画編集のアップデート
    def update
      #追記した部分ここから
      url = params[:post][:youtube_url].last(11)
      @post.youtube_url = url
      #ここまで
      if @post.update(post_params)
        redirect_to users_posts_path(@post), flash: {success: "動画編集完了致しました"}
      else
        flash.now[:danger] = '動画投稿出来ませんでした。'  # 4/25訂正
        render :new
      end
    end

    # 投稿動画削除
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
      @post = Post.find(params[:id])
    end

    # 投稿動画に関するカラム
    def post_params
      params.require(:post).permit(:title, :body, :youtube_url)
    end

    # 投稿したユーザーと現在のユーザーのidが違えばトップページに飛ばす
    def prevent_url
      @post = current_user.posts.find(params[:id])
      if @post.user_id != current_user.id
        redirect_to root_path
      end
    end
  end
end
