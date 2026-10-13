require 'rails_helper'

RSpec.describe 'コースのCRUD API', type: :request do
  let(:admin) { create(:admin) }
  let(:headers) do
    { 'Authorization' => "Bearer #{JwtHelper.encode(id: admin.id, role: 'admin')}" }
  end
  let(:path) { '/api/v1/admin/courses' }

  describe '一覧取得' do
    it '全コースのIDと名前をID順に返す' do
      first = create(:course, name: 'Ruby入門')
      second = create(:course, name: 'React入門')
      get path, headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['courses']).to eq([
        { 'id' => first.id.to_s, 'name' => first.name },
        { 'id' => second.id.to_s, 'name' => second.name }
      ])
    end

    it 'コースがない場合は空の一覧を返す' do
      get path, headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['courses']).to eq([])
    end
  end

  describe '新規作成' do
    it '名前を保存し、201を返す' do
      expect {
        post path, params: { name: 'Ruby入門' }, headers: headers, as: :json
      }.to change(Course, :count).by(1)
      expect(response).to have_http_status(:created)
      expect(Course.last.name).to eq('Ruby入門')
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
    let!(:course) { create(:course, name: '変更前') }
    let!(:other) { create(:course, name: '別のコース') }

    it '指定した1件だけ更新し、204を返す' do
      patch "#{path}/#{course.id}", params: { name: '変更後' }, headers: headers, as: :json
      expect(response).to have_http_status(:no_content)
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

    it '存在しないIDなら404を返す' do
      patch "#{path}/#{Course.maximum(:id) + 1}", params: { name: '変更後' }, headers: headers, as: :json
      expect(response).to have_http_status(:not_found)
      expect(course.reload.name).to eq('変更前')
    end
  end

  describe '削除' do
    let!(:course) { create(:course, name: '削除対象') }
    let!(:other) { create(:course, name: '残すコース') }

    it '指定した1件だけ削除し、204を返す' do
      expect {
        delete "#{path}/#{course.id}", headers: headers
      }.to change(Course, :count).by(-1)
      expect(response).to have_http_status(:no_content)
      expect(Course.exists?(course.id)).to be(false)
      expect(other.reload.name).to eq('残すコース')
    end

    it '存在しないIDなら削除せず404を返す' do
      expect {
        delete "#{path}/#{Course.maximum(:id) + 1}", headers: headers
      }.not_to change(Course, :count)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe '現在の認証制限' do
    let!(:course) { create(:course, name: '既存コース') }

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
