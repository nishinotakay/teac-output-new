require 'rails_helper'

RSpec.describe 'カテゴリー記事管理のテナント分離', type: :request do
  # DBの固定IDには依存せず、異なる2テナントをテストごとに作成する。
  around do |example|
    Current.reset
    example.run
  ensure
    Current.reset
  end

  let!(:tenant_one) { create(:tenant, name: '検証テナント1') }
  let!(:tenant_two) { create(:tenant, name: '検証テナント2') }
  let!(:admin_one) { create(:admin, tenant: tenant_one) }
  let!(:admin_two) { create(:admin, tenant: tenant_two) }
  let!(:course_one) { create(:course, tenant: tenant_one) }
  let!(:course_two) { create(:course, tenant: tenant_two) }
  let!(:category_one) { create(:category, course: course_one, tenant: tenant_one) }
  let!(:category_two) { create(:category, course: course_two, tenant: tenant_two) }
  let!(:linked_one) { create(:article, admin: admin_one, article_type: 'normal') }
  let!(:available_one) { create(:article, admin: admin_one, article_type: 'normal') }
  let!(:linked_two) { create(:article, admin: admin_two, article_type: 'normal') }
  let!(:available_two) { create(:article, admin: admin_two, article_type: 'normal') }
  let!(:link_one) { ArticleCategory.create!(category: category_one, article: linked_one) }
  let!(:link_two) { ArticleCategory.create!(category: category_two, article: linked_two) }
  let(:headers) do
    { 'Authorization' => "Bearer #{JwtHelper.encode(id: admin_one.id, role: 'admin')}" }
  end
  let(:articles_path) do
    "/api/v1/admin/courses/#{course_one.id}/categories/#{category_one.id}/articles"
  end
  let(:links_path) { "/api/v1/admin/categories/#{category_one.id}/articles" }

  def response_json
    JSON.parse(response.body)
  end

  it '同一テナントの記事だけを紐付け済み・追加可能一覧に返す' do
    get articles_path, headers: headers

    expect(response).to have_http_status(:ok)
    expect(response_json['linkedArticles'].map { |a| a['id'] }).to eq([linked_one.id.to_s])
    expect(response_json['availableArticles'].map { |a| a['id'] }).to eq([available_one.id.to_s])
    articles = response_json.values_at('linkedArticles', 'availableArticles').flatten
    expect(articles.map { |a| a['tenant_id'] }.uniq).to eq([tenant_one.id])
    expect(articles.map { |a| a['id'] }).not_to include(linked_two.id.to_s, available_two.id.to_s)
  end

  it '誤って他テナントの記事との中間レコードが存在しても一覧に漏らさない' do
    ArticleCategory.create!(category: category_one, article: linked_two)

    get articles_path, headers: headers

    expect(response).to have_http_status(:ok)
    expect(response_json['linkedArticles'].map { |a| a['id'] }).to eq([linked_one.id.to_s])
    expect(response_json['availableArticles'].map { |a| a['id'] }).to eq([available_one.id.to_s])
  end

  it '他テナントのコース・カテゴリーIDを指定した一覧取得は404にする' do
    get "/api/v1/admin/courses/#{course_two.id}/categories/#{category_two.id}/articles", headers: headers

    expect(response).to have_http_status(:not_found)
  end

  it '自テナントのコースに他テナントのカテゴリーIDを指定しても404にする' do
    get "/api/v1/admin/courses/#{course_one.id}/categories/#{category_two.id}/articles", headers: headers

    expect(response).to have_http_status(:not_found)
  end

  it '同一テナントの記事IDを直接指定すると記事を取得できる' do
    get "/api/v1/admin/articles/#{linked_one.id}", headers: headers

    expect(response).to have_http_status(:ok)
  end

  it '他テナントの記事IDを直接指定した記事取得は404にする' do
    get "/api/v1/admin/articles/#{linked_two.id}", headers: headers

    expect(response).to have_http_status(:not_found)
    expect(response.body).not_to include(linked_two.content)
  end

  it '他テナントの記事IDを指定した紐付けは404にして中間レコードを増やさない' do
    expect {
      post links_path, params: { articleIds: [available_two.id.to_s] }, headers: headers, as: :json
    }.not_to change(ArticleCategory, :count)

    expect(response).to have_http_status(:not_found)
  end

  it '自テナントと他テナントの記事を一括指定すると全件ロールバックする' do
    expect {
      post links_path, params: { articleIds: [available_one.id.to_s, available_two.id.to_s] }, headers: headers, as: :json
    }.not_to change(ArticleCategory, :count)

    expect(response).to have_http_status(:not_found)
    expect(ArticleCategory.exists?(category_id: category_one.id, article_id: available_one.id)).to eq(false)
  end

  it '他テナントの記事との不整合な紐付けを直接ID指定しても解除は404にする' do
    foreign_link = ArticleCategory.create!(category: category_one, article: linked_two)

    expect {
      delete "#{links_path}/#{linked_two.id}", headers: headers
    }.not_to change(ArticleCategory, :count)

    expect(response).to have_http_status(:not_found)
    expect(ArticleCategory.exists?(foreign_link.id)).to eq(true)
    expect(Article.unscoped.exists?(linked_two.id)).to eq(true)
  end

  it '同一テナントの記事は紐付けでき、返す一覧にも他テナントの記事は含まれない' do
    expect {
      post links_path, params: { articleIds: [available_one.id.to_s] }, headers: headers, as: :json
    }.to change(ArticleCategory, :count).by(1)

    expect(response).to have_http_status(:created)
    expect(response_json['linkedArticles'].map { |a| a['id'] }).to contain_exactly(linked_one.id.to_s, available_one.id.to_s)
    expect(response_json['availableArticles']).to eq([])
  end

  it '同一テナントの紐付けは解除でき、記事本体は残る' do
    expect {
      delete "#{links_path}/#{linked_one.id}", headers: headers
    }.to change(ArticleCategory, :count).by(-1)

    expect(response).to have_http_status(:no_content)
    expect(Article.unscoped.exists?(linked_one.id)).to eq(true)
    expect(ArticleCategory.exists?(link_two.id)).to eq(true)
  end

  it '認証なしでは一覧を取得できない' do
    get articles_path

    expect(response).to have_http_status(:unauthorized)
  end

  it 'Current.tenant設定時は通常検索とID検索の両方が絞り込まれる' do
    Current.tenant = tenant_one

    expect(Article.pluck(:id)).to contain_exactly(linked_one.id, available_one.id)
    expect { Article.find(linked_two.id) }.to raise_error(ActiveRecord::RecordNotFound)
    expect(Article.find(linked_one.id)).to eq(linked_one)
  end

  it 'Current.tenant未設定時とunscopedでは全テナントを参照できるという制限を記録する' do
    expect(Current.tenant).to be_nil
    expect(Article.pluck(:id)).to contain_exactly(linked_one.id, available_one.id, linked_two.id, available_two.id)

    Current.tenant = tenant_one
    expect(Article.unscoped.pluck(:id)).to contain_exactly(linked_one.id, available_one.id, linked_two.id, available_two.id)
  end
end
