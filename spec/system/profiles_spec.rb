require 'rails_helper'

RSpec.describe "Profiles", type: :system do
  scenario "user creates a new profile" do
    user = FactoryBot.create(:user, :a)

    #ログイン操作
    visit root_path
    fill_in "user[email]", with: user.email
    fill_in "user[password]", with: user.password
    click_button "ログイン"
    
    #プロフィール作成
    expect {
      click_link "プロフィール作成"
      fill_in "name", with: user.name
      fill_in "purpose", with: user.purpose
      click_button "登録する"
    }
  # before do
  #   driven_by(:rack_test)
  # end

  # pending "add some scenarios (or delete) #{__FILE__}"
  end
end
