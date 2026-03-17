Rails.application.routes.draw do
  get 'dashboard/index'
  get 'webhooks/stripe'
  get 'checkout/show'
  get 'checkout/create'
  get 'health/show'
  get 'health', to: 'health#show'
  
  # Stripe Checkout
  get '/pay', to: 'checkout#show'
  post '/create-checkout-session', to: 'checkout#create'
  post '/stripe/webhook', to: 'webhooks#stripe'
  
  # Pharma Transport Dashboard
  root 'dashboard#index'
  resources :batches, only: [:index, :show]
  resources :vehicles, only: [:index]
  
  # SPA fallback (Tailwind/React)
  get '*path', to: 'fallback#index', constraints: ->(req) { !req.xhr? && req.format.html? }
end

get '/success', to: 'checkout#success'
