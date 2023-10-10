module Users
  class PostsController < Users::Base
    before_action :authenticate_user!, only: %i[show index new create edit update destroy]
    before_action :set_post, only: %i[show edit update destroy]
    before_action :prevent_url, only: %i[edit update destroy]

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
        @posts = Post.includes(:admin, :user).order(created_at: params[:order]).page(params[:page]).per(30)
      else
        filter[:order] = params[:order]
        post_query = Post.includes(:admin)

        if filter[:author].present?
          post_query = post_query.joins(:user).where('name LIKE ?', "%#{filter[:author]}%")
        end

        if filter[:title].present?
          post_query = post_query.where('title LIKE ?', "%#{filter[:title]}%")
        end

        if filter[:body].present?
          post_query = post_query.where('body LIKE ?', "%#{filter[:body]}%")
        end

        if filter[:start].present? && filter[:finish].present?
          start_date = Time.zone.parse(filter[:start]).beginning_of_day
          finish_date = Time.zone.parse(filter[:finish]).end_of_day
          post_query = post_query.where('created_at >= ?', start_date).where('created_at <= ?', finish_date)
        end

        @posts = post_query.includes(:admin, :user).page(params[:page]).per(30)
      end
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
        flash.now[:danger] = '動画投稿出来ませんでした。'
        render :new
      end
    end

    def update
      url = params[:post][:youtube_url].last(11)
      @post.youtube_url = url
      if @post.update(post_params)
        redirect_to users_posts_path(@post), flash: { success: '動画編集完了致しました' }
      else
        flash.now[:danger] = '動画編集出来ませんでした。'
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

    # 投稿したユーザーと現在のユーザーのidが違えばトップページに飛ばす
    def prevent_url
      @post = current_user.posts.find(params[:id])
      if @post.user_id != current_user.id
        redirect_to root_path
      end
    end
  end
end
