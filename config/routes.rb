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
    resources :profiles
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
    resources :users, only: [:show ]
    resources :articles
    namespace :articles do
      post 'image'
    end
    namespace :users do
    resources :users, only: [:index]
    
    
    end
    resources :profiles
    
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
# end
