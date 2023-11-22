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
    resources :posts
    resources :dash_boards, only: [:index]
    resources :articles do
      member do
        get 'users_show'
        get 'users_edit'
        patch 'users_update'
        delete 'users_destroy'
      end
    end
    namespace :articles do
      post 'image'
    end
    resources :users do
      collection do
        get 'admins_show'
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
    registrations: 'users/registrations',
    omniauth_callbacks: 'users/omniauth_callbacks'
  }

  namespace :users do
    resources :dash_boards, only: [:index]
    resources :articles do
      resources :article_comments, only: %i[create destroy update] # 記事コメント機能
    end
    resources :users, only: [:show]
    resources :posts
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
      resources :tweet_comments, only: %i[create destroy update] do # コメント機能
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

  namespace :managers do
    resources :tenants, only: [:index, :show, :new, :create, :destroy]
    resources :profiles do
      collection do
        get 'managers_show'
      end
    end
  end
  # =================================================================

  # 共通==============================================================
  # 利用規約
  get 'use' => 'use#index'
  # =================================================================
end
