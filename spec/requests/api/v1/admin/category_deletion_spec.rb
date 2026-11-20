require 'rails_helper'

RSpec.describe 'カテゴリー削除API', type: :request do
  around do |example|
    Current.reset
    example.run
  ensure
    Current.reset
  end

  let(:admin) { create(:admin) }
  let(:headers) do
    { 'Authorization' => "Bearer #{JwtHelper.encode(id: admin.id, role: 'admin')}" }
  end
  let!(:course) { create(:course, tenant: admin.tenant) }
  let!(:category) { create(:category, course: course, tenant: admin.tenant, name: '削除対象') }
  let(:path) { "/api/v1/admin/courses/#{course.id}/categories/#{category.id}" }

  it '対象だけ削除し204を返す（コースと別カテゴリーは残る）' do
    other_category = create(:category, course: course, tenant: admin.tenant, name: '残す')

    expect { delete path, headers: headers }.to change(Category, :count).by(-1)
    expect(response).to have_http_status(:no_content)
    expect(Category.exists?(other_category.id)).to eq(true)
    expect(Course.exists?(course.id)).to eq(true)
  end

  it 'ログインなしでは削除しない' do
    expect { delete path }.not_to change(Category, :count)
    expect(response).to have_http_status(:unauthorized)
  end

  it '記事付きカテゴリーの削除は対象の紐付けだけを消し、記事・別カテゴリー・コースを残す' do
    other_category = create(:category, course: course, tenant: admin.tenant, name: '残す')
    article = create(:article, admin: admin, tenant: admin.tenant, article_type: 'normal')
    target_link = ArticleCategory.create!(category: category, article: article)
    remaining_link = ArticleCategory.create!(category: other_category, article: article)

    expect { delete path, headers: headers }.to change(Category.unscoped, :count).by(-1)

    expect(response).to have_http_status(:no_content)
    expect(ArticleCategory.exists?(target_link.id)).to eq(false)
    expect(remaining_link.reload).to have_attributes(category_id: other_category.id, article_id: article.id)
    expect(article.reload.admin_id).to eq(admin.id)
    expect(other_category.reload.name).to eq('残す')
    expect(course.reload.tenant_id).to eq(admin.tenant_id)
  end

  it '別コースのカテゴリーは削除せず404を返す' do
    other_course = create(:course, tenant: admin.tenant)
    expect {
      delete "/api/v1/admin/courses/#{other_course.id}/categories/#{category.id}", headers: headers
    }.not_to change(Category, :count)
    expect(response).to have_http_status(:not_found)
  end

  it 'カテゴリーがない場合は404を返す' do
    delete "/api/v1/admin/courses/#{course.id}/categories/#{Category.maximum(:id) + 1}", headers: headers
    expect(response).to have_http_status(:not_found)
  end

  it 'コースがない場合は404を返す' do
    expect {
      delete "/api/v1/admin/courses/#{Course.maximum(:id) + 1}/categories/#{category.id}", headers: headers
    }.not_to change(Category, :count)
    expect(response).to have_http_status(:not_found)
  end
end
