# frozen_string_literal: true

Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  # admin関連=========================================================
  devise_for :admins, controllers: {
    sessions: 'admins/sessions',
    passwords:     'admins/passwords',
    confirmations: 'admins/confirmations',
    registrations: 'admins/registrations'
  }
  
  namespace :admins do
    resources :dash_boards, only: [:index]
    resources :articles
    namespace :articles do
      post 'image'
    end
    resources :profiles do
      collection do
        get 'users_show'
        get 'users_edit'
        delete 'user_destroy'
      end
    end
  end


  # =================================================================

  # user関連==========================================================
  devise_scope :user do
    root 'users/sessions#new'
  end

  devise_for :users, controllers: {
    sessions:      'users/sessions',
    passwords:     'users/passwords',
    confirmations: 'users/confirmations',
    registrations: 'users/registrations'
  }

  namespace :users do
    resources :dash_boards, only: [:index]
    resources :articles #, only: %i[index show]
    resources :posts
    resources :users, only: [:show]
    resources :posts do
      collection do # idを外す
      # 全ユーザー投稿一覧（/users/posts/index_1）
      get 'index_1'
      end
      # 全ユーザー詳細ページ（/users/posts/:id/show_1）
      member do # id付与
        get 'show_1'
        get 'show'
        # 全ユーザー編集ページ（/users/posts/:id/edit_1）
        get 'edit_1'
        # 全ユーザー編集ページの更新（/users/posts/:id/update_1(）
        patch 'update_1'
      end
    end
    resources :articles
    namespace :articles do
      post 'image'
    end
    namespace :users do
    resources :users, only: [:index]
    end
    resources :profiles
    resources :tweets #つぶやき機能
    resources :inquiries #問い合わせ
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
