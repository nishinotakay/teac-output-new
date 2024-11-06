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
  end

  # ログイン前は tenant_id を含むURLを使用 ====================================================
  scope 'tenant/:tenant_id', as: 'tenant' do
    devise_for :users, skip: [:omniauth_callbacks], controllers: {
      sessions:      'users/sessions',
      passwords:     'users/passwords',
      confirmations: 'users/confirmations',
      registrations: 'users/registrations'
    }, as: :tenant_user
  end

  # OmniAuth コールバックをスコープ外に配置 ====================================================
  devise_for :users, only: :omniauth_callbacks, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks'
  }

  # ログイン後の通常のルート ====================================================
  devise_for :users, skip: [:omniauth_callbacks], controllers: {
    sessions:      'users/sessions',
    passwords:     'users/passwords',
    confirmations: 'users/confirmations',
    registrations: 'users/registrations'
  }

  # ダッシュボードへのルート
  get 'users/dash_boards', to: 'users/dash_boards#index', as: :users_dash_boards

  # その他のユーザー関連ルート
  namespace :users do
    resources :chat_rooms, only: [:create, :show]
    resources :stocks, only: [:create, :destroy, :index]
    resources :learnings, only: [:index, :show, :create]
    resources :folders, only: [:create, :show, :update, :destroy]
    resources :checkouts, only: [:new, :create] do
      get 'complete', on: :collection
    end
    resources :subscriptions, only: [:new, :create] do
      get 'complete', on: :collection
    end
    resources :articles do
      resources :article_comments, only: %i[create destroy update]
      resource :likes, only: [] do
        post 'article_create', on: :member
        delete 'article_destroy', on: :member
      end
      post 'assign_folder/:folder_id', to: 'article_folders#assign_folder', as: 'assign_folder'
    end
    resources :users do
      resource :posts, only: [] do
        get 'index_user', on: :member
      end
      resources :payments, only: [:index]
      resource :relationships, only: [:index, :create, :destroy]
        get :followings, :followers, on: :member
    end
    resources :users, only: [:show]
    resources :posts do
      resources :post_comments, only: %i[create destroy update]
      resource :likes, only: [] do
        post 'post_create', on: :member
        delete 'post_destroy', on: :member
      end
    end
    namespace :articles do
      post 'image'
    end
    resources :profiles
    resources :tweets do
      member do
        get 'index_user'
      end
      resources :tweet_comments, only: %i[create destroy update] do
        member do
          patch 'confirmed_notification'
        end
      end
    end
    resources :inquiries
  end

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

  # 共通==============================================================
  get 'use', to: 'use#index'
end
