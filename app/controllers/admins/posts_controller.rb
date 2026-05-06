# 管理者向け動画投稿コントローラ: 管理者がYouTube動画記事の一覧・作成・編集・削除を行うアクションを提供する

module Admins
  class PostsController < Admins::Base
    before_action :authenticate_admin!, only: %i[show index new create edit update destroy]
    before_action :set_post, only: %i[show edit update destroy]
    before_action :prevent_url, only: %i[edit update destroy]

    # 動画投稿一覧をフィルタ・ソート付きで表示する
    def index
      @posts = Post.filtered_and_ordered_posts(params, params[:page], 30)

      respond_to do |format|
        format.html
        format.json { render json: @posts }
      end
    end

    # 動画投稿の詳細を表示する
    def show
      @post = Post.find(params[:id])

      respond_to do |format|
        format.html
        format.json { render json: @post }
      end
    end

    # 新規動画投稿フォームを表示する
    def new
      @post = current_admin.posts.new
    end

    # 動画投稿編集フォームを表示する
    def edit
      respond_to do |format|
        format.html
        format.json { render json: @post }
      end
    end

    # 新規動画投稿を保存する（YouTubeURLから動画IDを抽出して保存）
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

    # 動画投稿情報を更新する
    def update
      url = params[:post][:youtube_url].last(11)
      @post.youtube_url = url
      if @post.update(post_params)
        redirect_to admins_posts_path(@post), flash: { success: '動画情報を更新しました' }
      else
        render :edit
      end
    end

    # 動画投稿を削除する
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
