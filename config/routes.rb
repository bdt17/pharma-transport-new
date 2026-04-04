# config/routes.rb - THOMAS IT PHARMA ENTERPRISE v12 (Compliance PDFs ✅)
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
  get '/dashboards', to: 'dashboards#index'
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

end
