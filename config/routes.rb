Rails.application.routes.draw do
  root "home#index"
  get "login", to: "sessions#new", as: :login
  post "login", to: "sessions#create"
  get "mfa", to: "sessions#mfa", as: :mfa
  post "mfa", to: "sessions#verify_mfa", as: :verify_mfa
  delete "logout", to: "sessions#destroy", as: :logout
  get "pdf-health", to: "home#pdf_health"
  
  post "lead_capture", to: "leads#create"
  resources :shipments
end
