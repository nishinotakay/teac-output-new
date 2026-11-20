class Api::V1::Admin::ArticleSearchController < Api::V1::BaseController
  before_action :authenticate_admin!

  def create
    query = params[:query]
    unless query.is_a?(String) && query.strip.length.between?(1, 500)
      return render json: { error: '検索文を1〜500文字で入力してください。' }, status: :unprocessable_entity
    end
    render json: GoogleArticleSearch.new.call(query.strip)
  rescue GoogleArticleSearch::NotConfigured => e
    render json: { error: e.message }, status: :service_unavailable
  rescue GoogleArticleSearch::SearchFailed => e
    render json: { error: e.message }, status: :bad_gateway
  end
end
