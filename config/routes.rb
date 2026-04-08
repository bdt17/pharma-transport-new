# config/routes.rb - THOMAS IT PHARMA ENTERPRISE v12 (Phase 12)
Rails.application.routes.draw do
  # 🩺 Health check (Render.com)
  get '/health', to: proc { [200, {}, ['OK']] }

  # 🔐 Authentication (MUST come first)
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions:      'users/sessions'
  }

  # 🏠 Landing page (public)
  root 'home#index'

  # 📊 Dashboard (auth + public)
  get '/dashboard', to: 'dashboard#index', as: :dashboard
  
  # 💳 Stripe payments
  post '/pay', to: 'payments#create'
  get '/success', to: 'payments#success'
  get '/cancel', to: 'payments#cancel'

  # 📄 PUBLIC Batch APIs + PDFs (no auth)
  resources :batches, only: [] do
    member do
      get :demo           # /batches/demo → JSON
      get :public_pdf, defaults: { format: :pdf }     # /batches/1/public_pdf.pdf
      get :chain_of_custody, defaults: { format: :pdf }  # /batches/1/chain_of_custody.pdf
    end
  end

  # 🚣 TENANT-SCOPED (auth required)
  namespace :tenant_scope do
    resources :batches
    resources :tenants
  end

  # 📄 Legacy PDF endpoints (Phase 11)
  get '/pdf', to: 'pdf_reports#show'
  get '/reports/compliance', to: 'reports#compliance'

  # 🛰️ GPS API (public)
  namespace :api do
    resources :gps, only: [:index, :show]
    resources :health, only: [:index]
  end

  # 💰 Webhooks
  post '/webhooks/stripe', to: 'webhooks#stripe'

  # Dev/debug
  get '/debug/zeitwerk', to: proc { Rails.application.eager_load!; [200, {}, ['Zeitwerk OK']] }
end

  resources :batches, only: [] do
    member do
      get :demo
      get :chain_of_custody
    end
  end
