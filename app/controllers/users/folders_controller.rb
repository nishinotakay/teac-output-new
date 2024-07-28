class Users::FoldersController < Users::Base

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
end
