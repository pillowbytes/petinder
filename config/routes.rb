Rails.application.routes.draw do
  get 'dev_tests', to: 'pets#dev_tests'

  devise_for :users

  # Pet Selection Routes (Outside `resources :pets` to avoid conflicts)
  get '/select_pet', to: 'pets#select', as: :select_pet
  post '/set_selected_pet', to: 'pets#set_selected_pet', as: :set_selected_pet

  resources :pets do
    member do
      patch 'process_swipe'
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
  root to: 'pages#home'

  get '/current_location', to: 'locations#current', as: :current_location

  get '/components', to: 'pages#index', as: 'components'

  # Messages Routes
  # get '/messages', to: 'matches#messages', as: 'messages'
end
