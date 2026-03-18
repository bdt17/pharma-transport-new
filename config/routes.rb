Rails.application.routes.draw do
  get 'health', to: 'health#show'
  
  # Stripe Checkout
  get '/pay', to: 'checkout#show'
  post '/create-checkout-session', to: 'checkout#create'
  get '/success', to: 'checkout#success'
  post '/stripe/webhook', to: 'webhooks#stripe'
  
  # Pharma Transport Dashboard
  root 'dashboard#index'
  resources :batches, only: [:index, :show]
  resources :vehicles, only: [:index]
end
