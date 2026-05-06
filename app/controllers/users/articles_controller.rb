# frozen_string_literal: true
# ユーザー向け記事コントローラ: ユーザーが記事の一覧・閲覧・作成・編集・削除・画像アップロードを行うアクションを提供する

module Users
  class ArticlesController < Users::Base
    protect_from_forgery
    before_action :check_article_owner, only: %i[edit update destroy]
    before_action :set_article, except: %i[index show new create image]
    before_action :set_dashboard, only: %i[show new create edit update destroy]
    skip_before_action :authenticate_user!, only: %i[show], if: :admin_signed_in?

    # 記事一覧をフィルタ・ページネーション付きで表示する
    def index
      filter = {
        author:   params[:author],
        title:    params[:title],
        subtitle: params[:subtitle],
        content:  params[:content],
        start:    params[:start],
        finish:   params[:finish],
        order:    params[:order] ||= 'DESC'
      }
  
      @articles = Article.includes(:likes).paginated_and_sort_filter(filter).page(params[:page]).per(30)

      respond_to do |format|
        format.html
        format.json { render json: @articles }
      end
    end

    # 記事の詳細・コメント一覧・ストック状態を表示する
    def show
      @article = Article.find(params[:id])
      @article_comments = @article.article_comments.all.order(created_at: 'DESC')
      @article_comment = current_user.article_comments.new unless current_admin.present?

      respond_to do |format|
        format.html
        format.json { render json: @article }
      end

      @stock = Stock.find_by(user_id: current_user.id, article_id: @article)
      @user = @article.user
    end

    # 新規記事作成フォームを表示する
    def new
      @article = current_user.articles.new
    end

    # 新規記事を保存する
    def create
      @article = current_user.articles.new(article_params)
    
      respond_to do |format|
        if @article.save
          format.html do
            flash[:notice] = '記事を作成しました。'
            redirect_to users_article_url(@article, dashboard: params[:dashboard], page: params[:page])
          end
          format.json { render json: @article, status: :created }
        else
          format.html do
            flash.now[:error] = '記事の作成に失敗しました。'
            render :new
          end
          format.json { render json: @article.errors, status: :unprocessable_entity }
        end
      end
    end    

    # 記事編集フォームを表示する
    def edit
      @show = params[:show].present?

      respond_to do |format|
        format.html
        format.json { render json: @article }
      end
    end

    # 記事を更新する
    def update
      respond_to do |format|
        if @article.update(article_params)
          format.html do
            flash[:notice] = '記事を編集しました。'
            redirect_to users_article_url(@article, dashboard: params[:dashboard], page: params[:page])
          end
          format.json { render json: @article, status: :ok }
        else
          format.html do
            flash.now[:alert] = '記事の編集に失敗しました。'
            render :edit
          end
          format.json { render json: @article.errors, status: :unprocessable_entity }
        end
      end
    end
    

    # 記事を削除する
    def destroy
      flash[:notice] = '記事を削除しました。'
      @article.destroy
      if @dashboard
        redirect_to users_dash_boards_path(current_user, page: params[:page])
      else
        redirect_to users_articles_path(page: params[:page])
      end
    end

    # 記事本文中の画像をアップロードしてURLを返す（リッチテキストエディタ用）
    def image
      if current_user.id == params[:user_id].to_i
        @article = current_user.articles.new(params.permit(:image))
        render json: { name: @article.image.identifier, url: @article.image.url }
      else
        render json: { error: '画像の挿入に失敗しました。' }, status: :unauthorized
      end
    end

    private

      def article_params
        params.require(:article).permit(:title, :sub_title, :content)
      end

      def set_article
        @article = current_user.articles.find_by(id: params[:id])
      end

      def check_article_owner
        @article = Article.find_by(id: params[:id])
        unless current_user.id == @article.user_id
          flash[:danger] = '不正な操作です。'
          redirect_to users_articles_path(page: params[:page])
        end
      end
      
      def set_dashboard
        params[:dashboard] ||= 'false'
        @dashboard = !(params[:dashboard] == 'false')
      end
  end
end
