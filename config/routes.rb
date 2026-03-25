Rails.application.routes.draw do
  root "pages#index"

  # Pharma Dashboard
  resources :batches, only: [:index, :show] do
    member do
      get :chain_of_custody, path: 'chain-of-custody', defaults: {format: 'pdf'}
    end
  end

  # Stripe Payments
  get '/pay', to: 'payments#checkout', as: :pay
  post '/webhook/stripe', to: 'payments#webhook'
  get '/payments/success', to: 'payments#success', as: :payments_success
  get '/payments/cancel', to: 'payments#cancel', as: :payments_cancel

  # Health & Status
  get "/health", to: proc { 
    [200, {"Content-Type" => "application/json"}, 
     [{ok: true, service: "pharma-transport", ts: Time.now.utc.iso8601}.to_json]] 
  }

  # Devise (login/signup - ready for later)
#  devise_for :users

  # Legacy redirects (optional)
  get "/batches/:id", to: redirect("/batches/%{id}")
end
