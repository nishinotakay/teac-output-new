class Users::ArticleFoldersController < ApplicationController
  before_action :authenticate_user!

  def assign_folder
    article_id = params[:article_id]
    old_folder_id = params[:old_folder_id]
    new_folder_id = params[:folder_id]
    
    if old_folder_id
      article_folder = ArticleFolder.find_by(article_id: article_id, folder_id: old_folder_id)
      old_folder = Folder.find_by(id: old_folder_id)
      new_folder = Folder.find_by(id: new_folder_id)

      if article_folder
        article_folder.destroy
      else
        render json: { success: false, errors: ["元のフォルダと記事の関連が見つかりません。"] } and return
      end
    end

    article_folder = ArticleFolder.new(assign_folder_params)

    if article_folder.save
      flash[:success] = "#{old_folder.name}から#{new_folder.name}に移動しました!"
      render json: { success: true, message: flash[:success] }
      flash.discard(:success)
    else
      render json: { success: false, errors: article_folder.errors.full_messages }
    end
  end

  private

    def assign_folder_params
      params.require(:article_folder).permit(:article_id, :folder_id, :user_id).merge(user_id: current_user.id)
    end

end

