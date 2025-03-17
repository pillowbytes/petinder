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
  end

  resources :matches, only: [:show]

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  root 'pages#home'
  get '/components', to: 'pages#index', as: 'components'

  # Match Routes
  # get '/swipe', to: 'matches#swipe', as: 'swipe'
end
