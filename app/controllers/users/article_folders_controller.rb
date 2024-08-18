class Users::ArticleFoldersController < ApplicationController

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

    article_folder = ArticleFolder.new(assign_folder_params)

    if article_folder.save
      render json: { success: true }
    else
      render json: { success: false, errors: article_folder.errors.full_messages }
    end
  end

  private

    def assign_folder_params
      params.require(:article_folder).permit(:article_id, :folder_id, :user_id)
    end

end
