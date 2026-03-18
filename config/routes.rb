Rails.application.routes.draw do
  root "home#index"
  resources :shipments
  # Emergency PDF endpoint
  get '/pdf-health', to: 'home#pdf_health'
end
