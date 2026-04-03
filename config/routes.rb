# config/routes.rb - THOMAS IT PHARMA ENTERPRISE v11 (Phase 11 Complete)
Rails.application.routes.draw do
  namespace :api do
    # 🛰️ GPS API (RESTful endpoints)
    resources :gps, only: [:index, :show]
  end

  # Health check (Render.com)
  get '/health', to: proc { [200, {}, ['OK']] }

  # 🔐 Authentication
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions:      'users/sessions'
  }

  # 📊 Dashboard
  get '/dashboard', to: 'dashboards#index'

  # 💳 Stripe (future)
  post '/pay', to: 'payments#create'
  get  '/success', to: 'payments#success'

  # 🏢 Multi‑tenant / subdomain‑style routes (uncomment when you wire up constraints)
  # constraints(SubdomainConstraint) do
  #   scope module: :tenant do
  #     resources :batches, only: [:index, :show] do
  #       get :public_pdf, on: :member
  #       get :chain_of_custody, on: :member
  #     end
  #     get '/batches/demo', to: 'batches#demo'
  #   end
  # end

  # 🚣 DEVELOPMENT / SINGLE‑TENANT (current live routes)
  scope module: :tenant_scope do
    resources :batches, only: [:index, :show] do
      get :public_pdf, on: :member        # → /batches/1/public_pdf
      get :chain_of_custody, on: :member  # → /batches/1/chain_of_custody
    end
    get '/batches/demo', to: 'batches#demo'  # → /batches/demo (JSON API)
  end

  # 📄 PDF Reports (demo / biologics‑style)
  get '/pdf', to: 'pdf_reports#show'

  # 🏠 Root
  root 'dashboards#index'
  get '/dashboards', to: 'dashboards#index'
end
