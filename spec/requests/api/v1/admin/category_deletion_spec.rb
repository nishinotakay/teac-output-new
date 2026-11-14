require 'rails_helper'

RSpec.describe 'カテゴリー削除API', type: :request do
  let(:admin) { create(:admin) }
  let(:headers) do
    { 'Authorization' => "Bearer #{JwtHelper.encode(id: admin.id, role: 'admin')}" }
  end
  let!(:course) { create(:course) }
  let!(:category) { create(:category, course: course, name: '削除対象') }
  let(:path) { "/api/v1/admin/courses/#{course.id}/categories/#{category.id}" }

  it '対象だけ削除し204を返す（コースと別カテゴリーは残る）' do
    other_category = create(:category, course: course, name: '残す')
    expect { delete path, headers: headers }.to change(Category, :count).by(-1)
    expect(response).to have_http_status(:no_content)
    expect(Category.exists?(other_category.id)).to eq(true)
    expect(Course.exists?(course.id)).to eq(true)
  end

  it 'ログインなしでは削除しない' do
    expect { delete path }.not_to change(Category, :count)
    expect(response).to have_http_status(:unauthorized)
  end

  it '別コースのカテゴリーは削除せず404を返す' do
    other_course = create(:course)
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
