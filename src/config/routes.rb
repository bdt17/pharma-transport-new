Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  
  devise_for :users
  
  # These MUST come AFTER devise_for
  get "/login", to: "devise/sessions#new", as: :login
  delete "/logout", to: "devise/sessions#destroy", as: :logout
  
  get "/dashboard", to: "dashboard#index"
  root "home#index"
end
