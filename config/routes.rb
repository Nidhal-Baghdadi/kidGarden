Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }

  authenticated :user do
    root "dashboard#index", as: :authenticated_root
  end

  devise_scope :user do
    root "users/sessions#new"
  end

  # Custom registration routes for different user types
  get '/register/teacher', to: 'registrations#new_teacher', as: 'new_teacher_registration'
  get '/register/parent', to: 'registrations#new_parent', as: 'new_parent_registration'
  post '/register/teacher', to: 'registrations#create_teacher'
  post '/register/parent', to: 'registrations#create_parent'

  # Admin approval routes
  namespace :admin do
    resources :registrations, only: [:index, :show] do
      member do
        patch :approve
        patch :reject
      end
    end
  end

  resources :students
  resources :classrooms
  resources :attendances
  resources :fees
  resources :payments do
    member do
      patch :refund
    end
  end
  resources :events

  resources :users, only: [:index, :show, :new, :create, :edit, :update]

  resources :notifications
  resources :parent_student_relationships, only: [:create, :destroy]
  resources :resources
  resources :calendar, only: [:index]

  # Messaging system
  resources :conversations, only: [:show, :create], constraints: { id: /\d+/ } do
    resources :messages, only: [:index, :create]
  end

  resources :messages, only: [:show, :destroy]
  get 'conversations', to: 'messages#conversations', as: 'user_conversations'
  get 'conversations/new', to: 'messages#new_conversation', as: 'new_user_conversation'
  post 'start_conversation', to: 'messages#start_conversation', as: 'start_the_conversation'

  # Parent management for admins and teachers
  resources :parents

  # Profile management
  get 'profile', to: 'profiles#show', as: 'profile'
  get 'profile/edit', to: 'profiles#edit', as: 'edit_profile'
  patch 'profile', to: 'profiles#update'

  # Photo sharing system
  resources :photos do
    member do
      patch :approve
    end
    collection do
      get :gallery
    end
  end

  mount ActionCable.server => "/cable"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
