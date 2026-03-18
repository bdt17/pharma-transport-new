Rails.application.routes.draw do
  get '/health', to: 'health#show'
  get '/pay', to: 'checkout#show'
  get '/success', to: 'checkout#success'
  get '/dashboard', to: 'dashboard#index'
  
  root 'health#show'
end
