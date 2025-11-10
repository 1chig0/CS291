Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Health check
  get '/health', to: 'health#index'

  # Authentication routes (session-based)
  namespace :auth do
    post 'register', to: 'auth#register'
    post 'login', to: 'auth#login'
    post 'logout', to: 'auth#logout'
    post 'refresh', to: 'auth#refresh'
    get 'me', to: 'auth#me'
  end

  # Conversations routes (JWT-based)
  resources :conversations, only: [:index, :show, :create] do
    resources :messages, only: [:index]
  end

  # Messages routes (JWT-based)
  resources :messages, only: [:create] do
    member do
      put :read
    end
  end

  # Expert routes (JWT-based)
  namespace :expert do
    get 'queue', to: 'expert#queue'
    post 'conversations/:conversation_id/claim', to: 'expert#claim'
    post 'conversations/:conversation_id/unclaim', to: 'expert#unclaim'
    get 'profile', to: 'expert#profile'
    put 'profile', to: 'expert#update_profile'
    get 'assignments/history', to: 'expert#assignments_history'
  end

  # Updates/Polling routes (JWT-based)
  namespace :api do
    get 'conversations/updates', to: 'updates#conversations'
    get 'messages/updates', to: 'updates#messages'
    get 'expert-queue/updates', to: 'updates#expert_queue'
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
