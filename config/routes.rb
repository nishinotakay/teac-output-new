# frozen_string_literal: true

Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  # admin関連=========================================================
  devise_for :admins, controllers: {
    sessions:      'admins/sessions',
    passwords:     'admins/passwords',
    confirmations: 'admins/confirmations',
    registrations: 'admins/registrations'
  }

  namespace :admins do
    resources :posts, only: [:destroy]
    resources :dash_boards, only: [:index]
    resources :articles
    resources :posts do
      collection do # idを外す
        # 全ユーザー投稿一覧（/admins/posts/index_1）
        get 'index_1'
      end
      # 全ユーザー詳細ページ（/admins/posts/:id/show_1）
      member do # id付与
        get 'show_1'
        get 'show'
        delete 'show'
        # 全ユーザー編集ページ（/admins/posts/:id/edit_1）
        get 'edit_1'
        # 全ユーザー編集ページの更新（/admins/posts/:id/update_1(）
        patch 'update_1'
      end
    end
    namespace :articles do
      post 'image'
    end
    resources :profiles do
      collection do
        get 'admins_show'
        get 'users_show'
        get 'users_edit'
        delete 'user_destroy'
      end
    end
    resources :inquiries
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
    resources :articles # , only: %i[index show]
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
    resources :tweets do # つぶやき機能
      member do
        get 'index_user'
      end
      resources :comments, only: %i[create destroy update] do # コメント機能
        member do # 個々のコメントに対してアクセスできるカスタムアクションを定義する
          patch 'confirmed_notification' # confirmed_notificationアクションに対するRESTfulなルーティングを定義
        end
      end
    end
    resources :inquiries
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

  # tenant関連========================================================
  resources :tenants, only: [:index]

  # =================================================================

  # 共通==============================================================
  # 利用規約
  get 'use' => 'use#index'
  # =================================================================
end
