# ユーザー向けフォルダコントローラ: ユーザーが記事整理用フォルダを作成・表示・編集・削除するアクションを提供する

class Users::FoldersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_folder, only: %i[show update destroy]

  # 新規フォルダを作成する
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

  # フォルダ内の記事一覧を表示する
  def show
    @article_folder = ArticleFolder.where(folder_id: @folder.id)
    article_ids = @article_folder.pluck(:article_id)
    @articles = Article.where(id: article_ids).page(params[:page])

    respond_to do |format|
      format.html
      format.js
    end
  end

  # フォルダ名を更新する
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

  # フォルダを削除する
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

