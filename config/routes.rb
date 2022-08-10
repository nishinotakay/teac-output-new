Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  # admin関連=========================================================
  devise_for :admins, controllers: {
    # /app/controllers/admins配下の、sessions_controller.rbが参照される
    sessions: 'admins/sessions'
  }

  # =================================================================
  # user関連==========================================================
  # UserモデルのDeviseコントローラを継承したスコープ
  devise_scope :user do
    root 'users/sessions#new'
  end

  # /app/controllers/users配下の、sessions、passwords、confirmations、registrationsコントローラーが参照される
  #【Rails】deviseのコントローラを独自にカスタマイズする方法
  # https://toarurecipes.com/devise-customize/
  # それぞれのコントローラーの、layout 'admins'
  #  →views/layouts/admins.html.erbを参照する
  #  【Rails】 layoutメソッドの使い方と使い所とは？ # https://pikawaka.com/rails/layout
  devise_for :users, controllers: {
    sessions:      'users/sessions',
    passwords:     'users/passwords',
    confirmations: 'users/confirmations',
    registrations: 'users/registrations'
  }

  # Railsのroutingにおけるscope / namespace / module の違い
  # https://qiita.com/ryosuketter/items/9240d8c2561b5989f049
  # users/の後に、dash_boards,articles,profileが続くpathになる
  # users/dash_boards/index
  namespace :users do
    resources :dash_boards, only: [:index]
    resources :articles #, only: %i[index show]
    # resources :articles #, only: %i[index show]
    
    #以下、ようせい追加
    namespace :articles do
      post "image"
    end
    #以上
    
    resource :profile, except: %i[create new]
  end

  # =================================================================
  # manager関連=======================================================
  devise_for :managers, controllers: {
    sessions:      'managers/sessions',
    passwords:     'managers/passwords',
    confirmations: 'users/confirmations',
    registrations: 'managers/registrations'
  }
  # =================================================================
  # 共通==============================================================
  # 利用規約
  get 'use' => 'use#index'
  # =================================================================
end