# config/routes.rb - FULL PHARMA ENTERPRISE ROUTES
Rails.application.routes.draw do
  root "pages#index"

  # 🔐 Authentication (Devise)
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }

  # 📊 Dashboard (login protected)
  get '/dashboard', to: 'dashboard#index'

  # 💳 Stripe Payments ✨ LIVE
  post '/pay', to: 'payments#create'
  get '/success', to: 'payments#success'
  get '/cancel', to: 'payments#cancel'

  # 📦 Batches (existing + enhanced)
  resources :batches, only: [:index, :new, :create, :show] do
    member do
      get :chain_of_custody  # PDF
    end
    collection do
      get :demo  # Sample data
    end
  end

  # 🛰️ GPS API (Queclink GV55)
  namespace :api do
    get '/gps', to: 'gps#index'
    post '/gps/track', to: 'gps#track'
    get '/health', to: 'health#index'
  end

  # 📄 PDF Chain of Custody (21 CFR)
  get '/pdf', to: 'pdfs#show', as: :pdf

  # 🚚 Quick actions
  get '/demo', to: 'pages#demo'

  # Legacy redirects
  get '/login', to: redirect('/users/sign_in')
  get '/register', to: redirect('/users/sign_up')

  # Health check (Render)
  get '/health', to: proc { [200, {}, ['OK']] }

  # Catch-all for SPA (future-proof)
  get '*path', to: 'pages#index', constraints: ->(req) { !req.xhr? && req.format.html? }
end
