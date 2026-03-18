Rails.application.routes.draw do
  root "home#index"
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  get 'mfa', to: 'sessions#mfa'
  post 'mfa', to: 'sessions#verify_mfa'
  delete 'logout', to: 'sessions#destroy'
  get 'pdf-health', to: 'home#pdf_health'
end
