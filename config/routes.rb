Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  # テナントのスコープを設定
  scope '/tenant/:tenant_id' do
    # admin関連=========================================================
    devise_for :admins, controllers: {
      sessions:      'admins/sessions',
      passwords:     'admins/passwords',
      confirmations: 'admins/confirmations',
      registrations: 'admins/registrations'
    }

    # ここにskip: :omniauth_callbacksを追加
    devise_for :users, skip: :omniauth_callbacks, controllers: {
      sessions:      'users/sessions',
      passwords:     'users/passwords',
      confirmations: 'users/confirmations',
      registrations: 'users/registrations'
    }

    namespace :users do
      resources :dash_boards, only: [:index]
      resources :folders, only: [:create, :show, :update, :destroy]
      resources :chat_rooms, only: [:create, :show]
      resources :stocks, only:[:create, :destroy, :index]
      resources :learnings, only: [:index, :show, :create]
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
  end

  # OmniAuth のコールバックはスコープの外で定義
  devise_for :users, only: :omniauth_callbacks, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks'
  }

  # 利用規約
  get 'use' => 'use#index'
end
