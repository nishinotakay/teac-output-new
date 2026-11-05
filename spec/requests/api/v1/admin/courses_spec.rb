require 'rails_helper'

RSpec.describe 'コースのCRUD API', type: :request do
  let(:admin) { create(:admin) }
  let(:headers) do
    { 'Authorization' => "Bearer #{JwtHelper.encode(id: admin.id, role: 'admin')}" }
  end
  let(:path) { '/api/v1/admin/courses' }
  let(:other_tenant) { create(:tenant) }

  describe '一覧取得' do
    it '自テナントの全コースのIDと名前をID順に返す' do
      first = create(:course, name: 'Ruby入門', tenant: admin.tenant)
      second = create(:course, name: 'React入門', tenant: admin.tenant)
      get path, headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['courses']).to eq([
        { 'id' => first.id.to_s, 'name' => first.name },
        { 'id' => second.id.to_s, 'name' => second.name }
      ])
    end

    it '他テナントのコースは一覧に含めない' do
      own = create(:course, name: '自テナント', tenant: admin.tenant)
      create(:course, name: '他テナント', tenant: other_tenant)
      get path, headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['courses']).to eq([{ 'id' => own.id.to_s, 'name' => '自テナント' }])
    end

    it 'コースがない場合は空の一覧を返す' do
      get path, headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['courses']).to eq([])
    end
  end

  describe '新規作成' do
    it '名前を保存し、作成したコースと201を返す' do
      expect {
        post path, params: { name: 'Ruby入門' }, headers: headers, as: :json
      }.to change(Course, :count).by(1)
      expect(response).to have_http_status(:created)
      expect(Course.last.name).to eq('Ruby入門')
      expect(JSON.parse(response.body)['course']).to eq(
        'id' => Course.last.id.to_s, 'name' => 'Ruby入門'
      )
    end

    it '作成したコースの tenant は管理者のテナントになる' do
      post path, params: { name: 'Ruby入門' }, headers: headers, as: :json
      expect(Course.unscoped.last.tenant_id).to eq(admin.tenant_id)
    end

    it 'params に他テナントの tenant_id を入れても管理者のテナントで作成する' do
      post path, params: { name: 'Ruby入門', tenant_id: other_tenant.id }, headers: headers, as: :json
      expect(response).to have_http_status(:created)
      expect(Course.unscoped.last.tenant_id).to eq(admin.tenant_id)
      expect(Course.unscoped.where(tenant_id: other_tenant.id).count).to eq(0)
    end

    it '名前が256文字なら保存せず422を返す' do
      expect {
        post path, params: { name: 'あ' * 256 }, headers: headers, as: :json
      }.not_to change(Course, :count)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['errors']).not_to be_empty
    end

    [nil, '', '   '].each do |name|
      it "名前が#{name.inspect}なら保存せず422を返す" do
        expect {
          post path, params: { name: name }, headers: headers, as: :json
        }.not_to change(Course, :count)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).not_to be_empty
      end
    end
  end

  describe '更新' do
    let!(:course) { create(:course, name: '変更前', tenant: admin.tenant) }
    let!(:other) { create(:course, name: '別のコース', tenant: admin.tenant) }

    it '指定した1件だけ更新し、更新後のコースと200を返す' do
      patch "#{path}/#{course.id}", params: { name: '変更後' }, headers: headers, as: :json
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['course']).to eq(
        'id' => course.id.to_s, 'name' => '変更後'
      )
      expect(course.reload.name).to eq('変更後')
      expect(other.reload.name).to eq('別のコース')
      expect(Course.count).to eq(2)
    end

    it '空の名前なら元の名前を維持し、422を返す' do
      patch "#{path}/#{course.id}", params: { name: '' }, headers: headers, as: :json
      expect(response).to have_http_status(:unprocessable_entity)
      expect(course.reload.name).to eq('変更前')
      expect(JSON.parse(response.body)['errors']).not_to be_empty
    end

    it '名前が256文字なら元の名前を維持し、422を返す' do
      patch "#{path}/#{course.id}", params: { name: 'あ' * 256 }, headers: headers, as: :json
      expect(response).to have_http_status(:unprocessable_entity)
      expect(course.reload.name).to eq('変更前')
      expect(JSON.parse(response.body)['errors']).not_to be_empty
    end

    it '他テナントのコースなら404を返し、名前を変更しない' do
      foreign = create(:course, name: '他テナント変更前', tenant: other_tenant)
      patch "#{path}/#{foreign.id}", params: { name: '乗っ取り' }, headers: headers, as: :json
      expect(response).to have_http_status(:not_found)
      expect(Course.unscoped.find(foreign.id).name).to eq('他テナント変更前')
    end

    it '存在しないIDなら404を返す' do
      patch "#{path}/#{Course.unscoped.maximum(:id) + 1}", params: { name: '変更後' }, headers: headers, as: :json
      expect(response).to have_http_status(:not_found)
      expect(course.reload.name).to eq('変更前')
    end
  end

  describe '削除' do
    let!(:course) { create(:course, name: '削除対象', tenant: admin.tenant) }
    let!(:other) { create(:course, name: '残すコース', tenant: admin.tenant) }

    it '指定した1件だけ削除し、204を返す' do
      expect {
        delete "#{path}/#{course.id}", headers: headers
      }.to change(Course, :count).by(-1)
      expect(response).to have_http_status(:no_content)
      expect(Course.exists?(course.id)).to be(false)
      expect(other.reload.name).to eq('残すコース')
    end

    it '他テナントのコースなら削除せず404を返す' do
      foreign = create(:course, name: '他テナント', tenant: other_tenant)
      expect {
        delete "#{path}/#{foreign.id}", headers: headers
      }.not_to change(Course.unscoped, :count)
      expect(response).to have_http_status(:not_found)
      expect(Course.unscoped.exists?(foreign.id)).to be(true)
    end

    it '存在しないIDなら削除せず404を返す' do
      expect {
        delete "#{path}/#{Course.unscoped.maximum(:id) + 1}", headers: headers
      }.not_to change(Course, :count)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe '現在の認証制限' do
    let!(:course) { create(:course, name: '既存コース', tenant: admin.tenant) }

    [:anonymous, :user].each do |role|
      context(role == :anonymous ? '未ログインの場合' : '一般ユーザーの場合') do
        let(:unauthorized_headers) do
          if role == :user
            user = create(:user)
            { 'Authorization' => "Bearer #{JwtHelper.encode(id: user.id, role: 'user')}" }
          else
            {}
          end
        end

        [:get, :post, :patch, :delete].each do |method|
          it "#{method.upcase}を拒否し、データを変更しない" do
            url = [:patch, :delete].include?(method) ? "#{path}/#{course.id}" : path
            public_send(method, url, params: { name: '不正な変更' }, headers: unauthorized_headers, as: :json)
            expect(response).to have_http_status(:unauthorized)
            expect(Course.count).to eq(1)
            expect(course.reload.name).to eq('既存コース')
          end
        end
      end
    end
  end
end
