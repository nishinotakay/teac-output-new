require 'rails_helper'

RSpec.describe ProfileDecorator do
  let(:user) { create(:user) }
  let(:user_profile) { FactoryBot.create(:profile).decorate }

  describe 'image' do
    context '画像が保存されている場合' do
      before do
        image = fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'ruby.png'))
        user_profile.object.image.attach(image)
      end

      it '保存された画像が返る' do
        expect(user_profile.image.filename.to_s).to eq 'ruby.png'
      end
    end

    context 'プロフィール画像が保存されていない場合' do
      it 'デフォルト画像が返る' do
        expect(user_profile.image).to end_with('user_default.png')
      end
    end
  end
end
