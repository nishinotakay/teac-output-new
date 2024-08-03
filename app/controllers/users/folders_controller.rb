class Users::FoldersController < ApplicationController
  before_action :authenticate_user!

  def create
    @folder = current_user.folders.new(folder_params)
    if @folder.save
      flash[:success] = "フォルダを作成しました。"
      redirect_to users_dash_boards_path
    else
      flash[:danger] = "作成に失敗しました。"
      redirect_to users_dash_boards_path
    end
  end

  def show
    folder_id = params[:folder_id]
    @article_folder = ArticleFolder.where(folder_id)
    article_ids = @article_folder.pluck(:article_id)
    @articles = Article.where(id: article_ids)
    
  end

  def assign_folder
    article_id = params[:article_id]
    folder_id = params[:folder_id]

    article_folder = ArticleFolder.new(article_id: article_id, folder_id: folder_id)

    if article_folder.save
      render json: { success: true }
    else
      render json: { success: false, errors: article_folder.errors.full_messages }
    end
  end

  private
  
    def folder_params
      params.require(:folder).permit(:name)
    end

end
