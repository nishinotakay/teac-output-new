require 'rails_helper'

RSpec.xdescribe 'UserSessions', type: :system do
  context 'ログインできることを確認' do
    let!(:user) { FactoryBot.create(:user, :a) }

    it 'ログインできることを確認' do
      visit new_user_session_path
      fill_in 'user[email]', with: user.email
      fill_in 'user[password]', with: user.password
      click_button 'ログイン'
    end
  end
end
