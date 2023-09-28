require 'rails_helper'

RSpec.describe "つぶやき機能", type: :system do
  let(:user) do
    user = create(:user, name: '山田太郎', email: Faker::Internet.email, password: 'password')
    user.confirm
    user
  end
  let(:tweet) { create(:tweet, post: "it's a sunny day!", user: user) }
  # let!(:tweet_comment) { FactoryBot.create_list(:tweet_comment, 3, content: "tweet_comment_test", user: user, tweet: tweet, recipient_id: tweet.user_id)}
  
  it 'ログインしてダッシュボードに遷移すること' do
    visit new_user_session_path
    fill_in 'user[email]', with: user.email
    fill_in 'user[password]', with: user.password
    click_button 'ログイン'
    expect(current_path).to eq users_dash_boards_path

    # click_on 'つぶやき一覧'
    # expect(current_path).to eq users_tweets_path
    # expect(page).to have_content 'つぶやき一覧'

    # find('.nav-link[data-remote="true"][data-method="get"][href="/users/tweets/new"]').click
    # expect(page).to have_selector('.modal', visible: true)
    # Capybara.default_max_wait_time = 5
    # expect(page).to have_selector('.modal', visible: true)
    
    # within('.modal') do
    #   expect(page).to have_content('投稿を作成')
    # end

  end
end
