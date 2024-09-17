require 'rails_helper'

RSpec.describe 'Profiles', type: :system do
  it 'user creates a new profile' do
    user = FactoryBot.create(:user, :a)

    # ログイン操作
    visit root_path
    fill_in 'user[email]', with: user.email
    fill_in 'user[password]', with: user.password
    click_button 'ログイン'

    # プロフィール作成
    subject do
      click_link 'プロフィール作成'
      fill_in 'purpose', with: user.learning_start
      fill_in 'purpose', with: user.purpose
      click_button '登録する'
    end
  end
end
