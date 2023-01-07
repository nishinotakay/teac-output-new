# frozen_string_literal: true

module Users
  class ArticlesController < Users::Base
    protect_from_forgery
    before_action :set_article, except: %i[index show new create image]

    def index
      params[:order] ||= 'DESC'
      @users = User.all
      @articles = Article.order(created_at: params[:order])
      params[:start] ||= Article.order(created_at: "ASC").first.created_at if params[:finish]
      params[:finish] ||= Date.current if params[:start]
      @articles &= Article.time_filter(params[:start], params[:finish]) if params[:start] && params[:finish]
      filter = {author: params[:author], title: params[:title], subtitle: params[:subtitle]}
      @articles &= Article.multi_filter(filter)

      # @articles = @articles.where('title like ?', "%#{params[:title]}%").where('sub_title like ?', "%#{params[:subtitle]}%")
      # params[:start] &&= params[:start].to_datetime
      # params[:finish] &&= params[:finish].to_datetime.end_of_day
      # @articles = @articles.where('created_at between ? and ?', params[:start], params[:finish]) if params[:start] && params[:finish]
      # @articles = @articles.where('created_at >= ?', params[:start]) if params[:start] && !params[:finish]
      # @articles = @articles.where('created_at <= ?', params[:finish]) if !params[:start] && params[:finish]
      # uids = params[:author] ? @users.where('name like ?', "%#{params[:author]}%").pluck(:id) : []
      # binding.pry
      # articles = []
      # uids.each{|id| articles << @articles.where(user_id: id)} if uids.present?
    end

    def show
      @article = Article.find(params[:id])
      @dashboard = params[:dashboard] == "false" ? false : true
    end

    def new
      @article = current_user.articles.new
    end

    def create
      @article = current_user.articles.new(article_params)
      if @article.save
        flash[:notice] = '記事を作成しました。'
        redirect_to users_article_url(@article)
      else
        flash.now[:alert] = '記事の作成に失敗しました。'
        render :new
      end
    end

    def edit
    end

    def update
      if @article.update(article_params)
        flash[:notice] = '記事を編集しました。'
        redirect_to users_article_url(@article)
      else
        flash.now[:alert] = '記事の編集に失敗しました。'
        render :edit
      end
    end

    def destroy
      flash[:notice] = '記事を削除しました。'
      @article.destroy
      dashboard = params[:dashboard] == "false" ? false : true
      if dashboard
        redirect_to users_dash_boards_path(current_user)
      else
        redirect_to users_articles_path
      end
    end

    def image
      user = User.find(params[:user_id])
      @article = user.articles.new(params.permit(:image))
      render json: { name: @article.image.identifier, url: @article.image.url }
    end

    private

    def article_params
      params.require(:article).permit(:title, :sub_title, :content)
    end

    # before_action

    def set_article
      @article = current_user.articles.find(params[:id])
    end
  end
end
