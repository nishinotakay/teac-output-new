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
    folder_id = params[:id]
    @article_folder = ArticleFolder.where(folder_id: folder_id)
    article_ids = @article_folder.pluck(:article_id)
    @articles = Article.where(id: article_ids).page(params[:page])
    @folder = Folder.find(params[:id])
    @folder_id = @folder.articles.includes(:user, :admin)
    @folder_view = params[:folder_view]

    respond_to do |format|
      format.html
      format.js
    end
  end

  def update
    @folder = Folder.find(params[:id])
    if @folder.present?
      @folder.update(folder_params)
      flash[:success] = "フォルダを編集しました。"
      redirect_to users_dash_boards_path
    else
      flash[:danger] = "編集に失敗しました。"
      redirect_to users_dash_boards_path
    end
  end

  def destroy
    @folder = Folder.find(params[:id])
    if @folder.present?
      @folder.destroy
      flash[:danger] = "フォルダを削除しました。"
      redirect_to users_dash_boards_path
    else
      flash[:danger] = "削除に失敗しました。"
      redirect_to users_dash_boards_path
    end
  end

  def assign_folder
    article_id = params[:article_id]
    old_folder_id = params[:old_folder_id]
    new_folder_id = params[:folder_id]
    user_id = current_user.id

    if old_folder_id
    article_folder = ArticleFolder.find_by(article_id: article_id, folder_id: old_folder_id)

    if article_folder
      article_folder.destroy
    else
      render json: { success: false, errors: ["元のフォルダと記事の関連が見つかりません。"] } and return
    end

    end 

    article_folder = ArticleFolder.new(article_id: article_id, folder_id: new_folder_id, user_id: user_id)

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
