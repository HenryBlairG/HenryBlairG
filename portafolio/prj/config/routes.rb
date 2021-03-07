# frozen_string_literal: true

Rails.application.routes.draw do
  resources :users, only: %i[index show edit update destroy] do
    member do
      post 'change_suspension'
      get 'transaction_maker'
      post 'account_router'
    end
    resources :debit_accounts, only: %i[new create show] do
      resources :transactions, only: %i[create new]
      get :transfer, controller: :transactions
      post :create_transfer, controller: :transactions
    end
    resources :checking_accounts, only: %i[new create show] do
      resources :transactions, only: %i[create new]
      get :transfer, controller: :transactions
      post :create_transfer, controller: :transactions
    end
    resources :credit_accounts, only: %i[new create show] do
      resources :transactions, only: %i[create new show]
      get :transfer, controller: :transactions
      post :create_transfer, controller: :transactions
    end
  end

  # post :liquid_installment, controller: :transactions
  post '/installments/:id' => 'installments#liquid', as: 'liquid'
  resources :categories, only: %i[index new create]
  devise_for :users, path: 'session'

  root to: 'pages#home'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
