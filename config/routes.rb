Rails.application.routes.draw do
  devise_for :users
  get 'home/index'
  resources :pets

  root "pages#index" # Página inicial

  get "up" => "rails/health#show", as: :rails_health_check
end
