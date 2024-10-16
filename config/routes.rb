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
    resources :charge_plans do
      collection do
        post 'confirm'
        get 'back'
        get 'complete'
      end
    end
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
    resources :learnings, only: [:index, :show, :create]
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
    resources :chat_rooms, only: [:create, :show]
    resources :stocks, only:[:create, :destroy, :index]
    resources :learnings, only: [:index, :show, :create]
    resources :folders, only: [:create, :show, :update, :destroy]
    resources :checkouts, only: [:new, :create] do
      get 'complete', on: :collection
    end
    resources :subscriptions, only: [:new, :create] do
      get 'complete', on: :collection
    end
    resources :articles do
      resources :article_comments, only: %i[create destroy update] # 記事コメント機能
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
