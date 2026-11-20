require 'rails_helper'

RSpec.describe '管理者の自然言語記事検索', type: :request do
  let(:admin) { create(:admin) }
  let(:headers) { { 'Authorization' => "Bearer #{JwtHelper.encode(id: admin.id, role: 'admin')}" } }
  let(:path) { '/api/v1/admin/article_search' }

  it '未認証では検索サービスを呼ばない' do
    expect(GoogleArticleSearch).not_to receive(:new)
    post path, params: { query: 'Ruby' }
    expect(response).to have_http_status(:unauthorized)
  end

  it '空欄なら422を返す' do
    post path, params: { query: ' ' }, headers: headers
    expect(response).to have_http_status(:unprocessable_entity)
  end

  it '未設定なら503と説明を返す' do
    allow_any_instance_of(GoogleArticleSearch).to receive(:call).and_raise(GoogleArticleSearch::NotConfigured, '検索アプリが未設定です。')
    post path, params: { query: 'Ruby' }, headers: headers
    expect(response).to have_http_status(:service_unavailable)
  end

  it '管理者に検索結果を返す' do
    allow_any_instance_of(GoogleArticleSearch).to receive(:call).with('Ruby').and_return(articles: [], total_count: 0, extracted_filters: '')
    post path, params: { query: ' Ruby ' }, headers: headers
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)['articles']).to eq([])
  end
end
