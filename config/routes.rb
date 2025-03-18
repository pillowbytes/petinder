Rails.application.routes.draw do
  get 'dev_tests', to: 'pets#dev_tests'

  devise_for :users

  resources :pets do
    member do
      post 'process_swipe'
      get 'swipe'
    end

    collection do
      get 'dev_tests' # Custom route to view test data
    end

    resources :matches, only: [:index, :show] do
      get 'messages', to: 'matches#messages' # `/pets/:id/matches/:id/messages`
      resources :messages, only: [:create] # Messages should be nested under matches inside pets
    end
  end

  resources :matches, only: [:index, :show] do
    resources :messages, only: [:create] # This is the global matches/messages route (for now)
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  root 'pages#home'
  get '/components', to: 'pages#index', as: 'components'

  # Messages Routes
  # get '/messages', to: 'matches#messages', as: 'messages'
end
