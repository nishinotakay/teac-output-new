require 'rails_helper'

RSpec.describe 'カテゴリー管理API', type: :request do
  around do |example|
    Current.reset
    example.run
  ensure
    Current.reset
  end

  let!(:tenant) { create(:tenant) }
  let!(:other_tenant) { create(:tenant) }
  let!(:admin) { create(:admin, tenant: tenant) }
  let!(:user) { create(:user, tenant: tenant) }
  let!(:course) { create(:course, tenant: tenant) }
  let!(:other_course) { create(:course, tenant: other_tenant) }
  let!(:category) { create(:category, course: course, tenant: tenant, name: '基本文法') }
  let!(:other_category) { create(:category, course: other_course, tenant: other_tenant, name: '他テナント') }
  let(:headers) { { 'Authorization' => "Bearer #{JwtHelper.encode(id: admin.id, role: 'admin')}" } }
  let(:collection_path) { "/api/v1/admin/courses/#{course.id}/categories" }
  let(:member_path) { "#{collection_path}/#{category.id}" }

  def response_json
    JSON.parse(response.body)
  end

  describe 'GET /api/v1/admin/courses/:course_id/categories' do
    it '選択コースのカテゴリーをID昇順で返す' do
      second_category = create(:category, course: course, tenant: tenant, name: '応用文法')

      get collection_path, headers: headers

      expect(response).to have_http_status(:ok)
      expect(response_json['course']).to include('id' => course.id.to_s, 'name' => course.name)
      expect(response_json['categories']).to eq([
        { 'id' => category.id.to_s, 'name' => '基本文法' },
        { 'id' => second_category.id.to_s, 'name' => '応用文法' }
      ])
    end

    it 'カテゴリーのないコースでは空配列を返す' do
      empty_course = create(:course, tenant: tenant)

      get "/api/v1/admin/courses/#{empty_course.id}/categories", headers: headers

      expect(response).to have_http_status(:ok)
      expect(response_json['categories']).to eq([])
    end

    it '他テナントのコースは404にする' do
      get "/api/v1/admin/courses/#{other_course.id}/categories", headers: headers

      expect(response).to have_http_status(:not_found)
      expect(other_category.reload.name).to eq('他テナント')
    end
  end

  describe 'POST /api/v1/admin/courses/:course_id/categories' do
    it '名前の前後空白を除去して作成し201を返す' do
      expect {
        post collection_path, params: { name: '  応用文法  ' }, headers: headers, as: :json
      }.to change(Category.unscoped, :count).by(1)

      expect(response).to have_http_status(:created)
      saved_category = Category.unscoped.find(response_json.fetch('category').fetch('id'))
      expect(response_json['category']).to include('id' => saved_category.id.to_s, 'name' => '応用文法')
      expect(saved_category).to have_attributes(name: '応用文法', course_id: course.id, tenant_id: tenant.id)
    end

    it 'bodyのcourse_idとtenant_idではURLの所属を上書きできない' do
      post collection_path,
        params: { name: '所属確認', course_id: other_course.id, tenant_id: other_tenant.id },
        headers: headers, as: :json

      expect(response).to have_http_status(:created)
      saved_category = Category.unscoped.find(response_json.fetch('category').fetch('id'))
      expect(saved_category).to have_attributes(course_id: course.id, tenant_id: tenant.id)
    end

    [nil, '', '   ', 'あ' * 256].each do |invalid_name|
      it "名前が#{invalid_name&.length == 256 ? '256文字' : invalid_name.inspect}なら422で保存しない" do
        expect {
          post collection_path, params: { name: invalid_name }, headers: headers, as: :json
        }.not_to change(Category.unscoped, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response_json['errors']).to be_an(Array)
        expect(response_json['errors']).not_to be_empty
      end
    end

    it '他テナントのコースでは作成せず404にする' do
      expect {
        post "/api/v1/admin/courses/#{other_course.id}/categories",
          params: { name: '作成不可' }, headers: headers, as: :json
      }.not_to change(Category.unscoped, :count)

      expect(response).to have_http_status(:not_found)
      expect(other_category.reload.name).to eq('他テナント')
    end
  end

  describe 'PATCH /api/v1/admin/courses/:course_id/categories/:id' do
    it '名前を更新して200と保存結果を返す' do
      patch member_path, params: { name: '  応用文法  ' }, headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(response_json['category']).to include('id' => category.id.to_s, 'name' => '応用文法')
      expect(category.reload).to have_attributes(name: '応用文法', course_id: course.id, tenant_id: tenant.id)
    end

    [nil, '', '   ', 'あ' * 256].each do |invalid_name|
      it "名前が#{invalid_name&.length == 256 ? '256文字' : invalid_name.inspect}なら422で元の名前を保持する" do
        patch member_path, params: { name: invalid_name }, headers: headers, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response_json['errors']).to be_an(Array)
        expect(response_json['errors']).not_to be_empty
        expect(category.reload.name).to eq('基本文法')
      end
    end

    it '同一テナントの別コースのカテゴリーは404で変更しない' do
      another_course = create(:course, tenant: tenant)

      patch "/api/v1/admin/courses/#{another_course.id}/categories/#{category.id}",
        params: { name: '変更不可' }, headers: headers, as: :json

      expect(response).to have_http_status(:not_found)
      expect(category.reload.name).to eq('基本文法')
    end

    it '他テナントのカテゴリーは404で変更しない' do
      patch "/api/v1/admin/courses/#{other_course.id}/categories/#{other_category.id}",
        params: { name: '変更不可' }, headers: headers, as: :json

      expect(response).to have_http_status(:not_found)
      expect(other_category.reload.name).to eq('他テナント')
    end
  end

  describe '管理操作の認証' do
    { '未認証' => nil, '一般ユーザー' => 'user' }.each do |role_name, role|
      context role_name do
        let(:rejected_headers) do
          role ? { 'Authorization' => "Bearer #{JwtHelper.encode(id: user.id, role: role)}" } : {}
        end

        it '一覧を401で拒否する' do
          get collection_path, headers: rejected_headers
          expect(response).to have_http_status(:unauthorized)
        end

        it '作成を401で拒否しDBを変更しない' do
          expect {
            post collection_path, params: { name: '作成不可' }, headers: rejected_headers, as: :json
          }.not_to change(Category.unscoped, :count)
          expect(response).to have_http_status(:unauthorized)
        end

        it '更新を401で拒否し元の名前を保持する' do
          patch member_path, params: { name: '変更不可' }, headers: rejected_headers, as: :json
          expect(response).to have_http_status(:unauthorized)
          expect(category.reload.name).to eq('基本文法')
        end

        it '削除を401で拒否し対象を保持する' do
          expect {
            delete member_path, headers: rejected_headers
          }.not_to change(Category.unscoped, :count)
          expect(response).to have_http_status(:unauthorized)
          expect(category.reload.name).to eq('基本文法')
        end

        it '記事一覧を401で拒否する' do
          get "#{member_path}/articles", headers: rejected_headers
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end
end
