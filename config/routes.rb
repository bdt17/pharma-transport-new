# config/routes.rb - THOMAS IT PHARMA ENTERPRISE v12 (Phase 11)
Rails.application.routes.draw do
  # 🩺 Health check (Render.com)
  get '/health', to: proc { [200, {}, ['OK']] }

  # 🔐 Authentication (MUST come first)
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions:      'users/sessions'
  }

  # 📊 Dashboard (auth required except for testing)
  authenticated :user do
    get '/dashboard', to: 'dashboards#index', as: :dashboard
    get '/dashboards', to: 'dashboards#index'
  end
  # Temporary public access (remove in production)
  get '/dashboard', to: 'dashboards#index', as: :public_dashboard

  root 'dashboards#index'

  # 💳 Stripe (future)
  post '/pay', to: 'payments#create'
  get  '/success', to: 'payments#success'

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

  # ✅ COMPLIANCE REPORTS (NEW - HTML + PDF)
  get '/reports/compliance', to: 'reports#compliance'  # → /reports/compliance (.pdf auto)

  # 🛰️ GPS API (RESTful endpoints)
  namespace :api do
    resources :gps, only: [:index, :show]
  end
end
