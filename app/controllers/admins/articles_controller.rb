# 管理者向け記事コントローラ: 管理者（講師）が記事の一覧・作成・編集・削除・画像アップロードを行うアクションを提供する

module Admins
  class ArticlesController < Admins::Base
    protect_from_forgery
    before_action :authenticate_admin!
    before_action :set_article, except: %i[index new create image]
    before_action :set_dashboard, only: %i[show new create edit update destroy]

    # 記事一覧を取得してフィルタリング・ページネーションして表示する
    def index
      params[:order] ||= 'DESC'
      filter = {
        author:   params[:author],
        title:    params[:title],
        subtitle: params[:subtitle],
        content:  params[:content],
        start:    params[:start],
        finish:   params[:finish],
        order:    params[:order]
      }
  
      @articles = Article.paginated_and_sort_filter(filter).page(params[:page])
    end

    # 記事の詳細を表示する
    def show; end

    # 記事に紐づくユーザー情報を表示する
    def users_show
      @user = @article.user
    end

    # ユーザーの記事を管理者が更新する
    def users_update
      if @article.update(article_params)
        flash[:notice] = '記事を編集しました。'
        redirect_to users_show_admins_article_url(@article, dashboard: params[:dashboard], page: params[:page])
      else
        flash.now[:alert] = '記事の編集に失敗しました。'
        render :edit
      end
    end

    # 新規記事作成フォームを表示する
    def new
      @article = current_admin.articles.new
    end

    # 新規記事を保存する
    def create
      @article = current_admin.articles.new(article_params)
      if @article.save
        flash[:notice] = '記事を作成しました。'
        redirect_to admins_article_url(@article, dashboard: params[:dashboard], page: params[:page])
      else
        flash.now[:alert] = '記事の作成に失敗しました。'
        render :new
      end
    end

    # 記事編集フォームを表示する
    def edit; end

    # ユーザーの記事編集フォームを表示する
    def users_edit
      @user = @article.user
    end

    # 記事を更新する
    def update
      if @article.update(article_params)
        flash[:notice] = '記事を編集しました。'
        redirect_to admins_article_url(@article, dashboard: params[:dashboard], page: params[:page])
      else
        flash.now[:alert] = '記事の編集に失敗しました。'
        render :edit
      end
    end

    # 記事を削除する
    def destroy
      flash[:notice] = '記事を削除しました。'
      @article.destroy
      if @dashboard
        redirect_to admins_dash_boards_path(current_admin, page: params[:page])
      else
        redirect_to admins_articles_path(page: params[:page])
      end
    end

    # ユーザーの記事を管理者が削除する
    def users_destroy
      flash[:notice] = '記事を削除しました。'
      @article.destroy
      redirect_to admins_articles_path(current_admin, page: params[:page])
    end

    # 記事本文中の画像をアップロードしてURLを返す（リッチテキストエディタ用）
    def image
      admin = Admin.find(params[:admin_id])
      @article = admin.articles.new(params.permit(:image))
      render json: { name: @article.image.identifier, url: @article.image.url }
    end

    private

    def article_params
      params.require(:article).permit(:title, :sub_title, :content, :article_type)
    end

    # before_action

    def set_article
      @article = Article.find(params[:id])
    end

    def set_dashboard
      params[:dashboard] ||= 'false'
      @dashboard = (params[:dashboard] != 'false')
    end
  end
end
