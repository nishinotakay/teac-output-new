class Users::FoldersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_folder, only: %i[show update destroy]

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
    @article_folder = ArticleFolder.where(folder_id: @folder.id)
    article_ids = @article_folder.pluck(:article_id)
    @articles = Article.where(id: article_ids).page(params[:page])

    respond_to do |format|
      format.html
      format.js
    end
  end

  def update
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
    if @folder.present?
      @folder.destroy
      flash[:danger] = "フォルダを削除しました。"
      redirect_to users_dash_boards_path
    else
      flash[:danger] = "削除に失敗しました。"
      redirect_to users_dash_boards_path
    end
  end

  private

    def set_folder
      @folder = Folder.find(params[:id])
    end
  
    def folder_params
      params.require(:folder).permit(:name)
    end

end
