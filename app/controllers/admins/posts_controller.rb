module Admins
  class PostsController < Admins::Base
    # Userがログインしていないと、投稿を作成・編集・削除できない
    before_action :authenticate_admin!, only: %i[show index new create edit update destroy]
    before_action :set_post, only: %i[show edit update destroy]
    # 投稿したユーザーと現在のユーザーのidが違えばトップページに飛ばす
    before_action :prevent_url, only: %i[edit update destroy]

    # 投稿動画一覧ページ
    def index
      params[:order] ||= 'DESC'
      filter = {
        author: params[:author],
        body:   params[:body],
        title:  params[:title],
        start:  params[:start],
        finish: params[:finish]
      }

      if filter.compact.blank?
        @paginate = true
        @posts = Post.includes(:user, :admin).order(created_at: params[:order]).page(params[:page]).per(30)
        @articles = Article.includes(:user, :admin).order(created_at: params[:order]).page(params[:page]).per(30)
      else
        filter[:order] = params[:order]
        post_query = Post.includes(:user, :admin).all
        article_query = Article.includes(:user, :admin).all

        if filter[:author].present?
          post_query = post_query.left_joins(:user, :admin).includes(:user, :admin)
            .where('users.name LIKE ? OR admins.name LIKE ?', "%#{filter[:author]}%", "%#{filter[:author]}%")
          article_query = article_query.left_joins(:user, :admin).includes(:user, :admin)
            .where('users.name LIKE ? OR admins.name LIKE ?', "%#{filter[:author]}%", "%#{filter[:author]}%")
        end
        
        if filter[:title].present?
          post_query = post_query.where('title LIKE ?', "%#{filter[:title]}%")
          article_query = article_query.where('title LIKE ?', "%#{filter[:title]}%")
        end

        if filter[:body].present?
          post_query = post_query.where('body LIKE ?', "%#{filter[:body]}%")
          article_query = article_query.where('body LIKE ?', "%#{filter[:body]}%")
        end

        if filter[:start].present? && filter[:finish].present?
          start_date = Time.zone.parse(filter[:start]).beginning_of_day
          finish_date = Time.zone.parse(filter[:finish]).end_of_day
          post_query = post_query.where('created_at >= ?', start_date).where('created_at <= ?', finish_date)
          article_query = article_query.where('created_at >= ?', start_date).where('created_at <= ?', finish_date)
        end

        @posts = post_query.page(params[:page]).per(30)
        @articles = article_query.page(params[:page]).per(30)
      end
    end

    def show
      @post = Post.find(params[:id])
    end

    # 新規投稿ページ
    def new
      @post = current_admin.posts.new
    end

    # 投稿動画編集ページ
    def edit; end

    # 投稿動画作成
    def create
      @post = current_admin.posts.new(post_params)
      url = params[:post][:youtube_url].last(11)
      @post.youtube_url = url
      if @post.save
        redirect_to admins_post_path(@post), flash: { success: '動画投稿完了致しました' }
      else
        flash.now[:danger] = '動画投稿出来ませんでした。'
        render :new
      end
    end

    # 投稿動画編集のアップデート
    def update
      url = params[:post][:youtube_url].last(11)
      @post.youtube_url = url
      if @post.update(post_params)
        redirect_to admins_posts_path(@post), flash: { success: '動画編集完了致しました' }
      else
        flash.now[:danger] = '動画編集出来ませんでした。'
        render :edit
      end
    end

    # 投稿動画削除
    def destroy
      if @post.destroy
        redirect_to admins_posts_path, flash: { warning: '動画を削除しました。' }
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
      @post = current_admin.posts.find(params[:id])
      if @post.admin_id != current_admin.id
        redirect_to root_path
      end
    end
  end
end
