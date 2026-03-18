Rails.application.routes.draw do
  root "home#index"
  
  # AUTH ROUTES FIRST (higher priority)
  get "login", to: "sessions#new"
  post "login", to: "sessions#create", as: :login
  delete "logout", to: "sessions#destroy", as: :logout
  
  get "pdf-health", to: "home#pdf_health"
  
  # Protected resources
  resources :shipments
end
