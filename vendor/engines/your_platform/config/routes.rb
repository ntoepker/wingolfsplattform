require 'sidekiq/web'

Rails.application.routes.draw do

  root :to => 'root#index'
  get :setup, to: 'setup#index'
  post :setup, to: 'setup#create'
  
  get :terms, to: 'terms_of_use#index'
  post :terms, to: 'terms_of_use#accept'
  
  devise_for :user_accounts, :controllers => {:sessions => 'sessions'}
  devise_scope :user_account do
    match 'sign_in' => 'sessions#new', as: :sign_in
    match 'sign_out' => 'sessions#destroy', as: :sign_out
  end
  
  get 'search/guess', to: "search#lucky_guess"
  get :search, to: "search#index"

  mount Judge::Engine => '/judge'

  resources :users do
    get :autocomplete_title, on: :collection
    put :forgot_password, on: :member
    get :events, to: 'events#index'
    get :settings, to: 'user_settings#show'
    put :settings, to: 'user_settings#update'
  end
  get :settings, to: 'user_settings#index'

  resources :groups do
    get :mine, on: :collection, to: 'groups#index_mine'
    get 'events/public', to: 'events#index', published_on_local_website: true
    get :events, to: 'events#index'
    resources :posts
  end
  get :my_groups, to: 'groups#index_mine'
  
  resources :pages
  
  post :create_officers_group, to: 'officers#create_officers_group'

  resources :user_accounts
  resources :blog_posts
  resources :attachments
  resources :profile_fields  
  resources :workflows
  resources :user_group_memberships
  resources :status_group_memberships
  resources :relationships

  get 'events/public', to: 'events#index', published_on_global_website: true, all: true, as: 'public_events'
  resources :events do
    post :join, to: 'events#join'
    get :join, to: 'events#join_via_get', as: 'join_via_get'
    delete :leave, to: 'events#leave'
    post 'invite/:recipient', to: 'events#invite', as: 'invite'
  end
  
  put 'workflow_kit/workflows/:id/execute', to: 'workflows#execute'
  mount WorkflowKit::Engine => "/workflow_kit", as: 'workflow_kit'
  
  get :statistics, to: 'statistics#index', as: 'statistics_index'
  get "/statistics/:list", to: 'statistics#show', as: 'statistics'

  resources :bookmarks
  get :my_bookmarks, controller: "bookmarks", action: "index"

  # Sidekiq Web UI
  sidekiq_constraint = lambda do |request|
    request.env['warden'].authenticate? && request.env['warden'].user.user.global_admin?
  end
  constraints sidekiq_constraint do
    mount Sidekiq::Web => '/sidekiq'
  end
  
  get "/attachments/:id(/:version)/*basename.:extension", controller: 'attachments', action: 'download', as: 'attachment_download'
    
  get ':alias', to: 'users#show'
  
end
