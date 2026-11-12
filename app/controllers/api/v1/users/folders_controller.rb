class Api::V1::Users::FoldersController < Api::V1::BaseController
  before_action :authenticate_user!
  # 「未分類」を先に用意し、同じ名前を付ける作成・変更を一意チェックで弾く
  before_action :set_default_folder
  before_action :set_folder, only: [:update, :destroy]
  before_action :reject_default_folder, only: [:update, :destroy]

  # GET /api/v1/folders
  def index
    articles_counts = @current_user.folder_articles_counts
    folders = @current_user.folders.order(:id).partition(&:default?).flatten
    render json: { folders: folders.map { |folder| folder_json(folder, articles_count: articles_counts.fetch(folder.id, 0)) } }
  end

  # POST /api/v1/folders
  def create
    folder = @current_user.folders.build(folder_params)
    if folder.save
      render json: { folder: folder_json(folder) }, status: :created
    else
      render json: { errors: folder.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /api/v1/folders/:id
  def update
    if @folder.update(folder_params)
      render json: { folder: folder_json(@folder, articles_count: @folder.article_folders.count) }
    else
      render json: { errors: @folder.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/folders/:id
  def destroy
    @folder.destroy_moving_articles_to!(@default_folder)
    render json: { folder: folder_json(@folder) }
  end

  private

  def set_default_folder
    @default_folder = @current_user.default_folder
  end

  def set_folder
    @folder = @current_user.folders.find_by(id: params[:id])
    render_not_found('フォルダ') unless @folder
  end

  def reject_default_folder
    return unless @folder.default?

    render json: { errors: ['「未分類」フォルダは変更・削除できません'] }, status: :unprocessable_entity
  end

  def folder_params
    params.permit(:name)
  end

  def folder_json(folder, articles_count: 0)
    {
      id:            folder.id.to_s,
      name:          folder.name,
      isDefault:     folder.default?,
      articlesCount: articles_count,
      createdAt:     folder.created_at.iso8601
    }
  end
end
