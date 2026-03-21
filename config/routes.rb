Rails.application.routes.draw do
  devise_for :users
  root "home#index"

  # AUTH
  get "login", to: "sessions#new", as: :login
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout

  # PAYMENTS - Stripe Production
  get 'payments/checkout',              to: 'payments#checkout'
  post 'payments/create_payment_intent', to: 'payments#create_payment_intent'
  get  'payments/success',              to: 'payments#success'
  get '/payments/debug', to: 'payments#debug'
  get  'payments/cancel',               to: 'payments#cancel'
  post '/stripe/webhook',              to: 'payments#webhook'

  # PDF (CRITICAL - 21 CFR)
  get "pdf-health",                     to: "home#pdf_health"
  get "pdf/chain-of-custody",           to: "pdf#chain_of_custody", as: :chain_of_custody_pdf

  # LEADS
  post "lead_capture",                  to: "leads#create"
  get '/webhook-test', to: ->(_) { [200, {'Content-Type' => 'text/plain'}, ['OK']] }
  get '/checkout-test', to: proc { [200, {'Content-Type' => 'text/plain'}, ['OK']] }

end
