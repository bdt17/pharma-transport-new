Rails.application.routes.draw do
  # 🩺 1. Health check (ALWAYS first for Render.com)
  get '/health', to: proc { [200, {}, ['OK']] }

  # 🔐 2. Devise authentication (MUST come first)
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions:      'users/sessions'
  }

  # 🏠 3. Public landing + dashboard
  root 'home#index'
  get '/dashboard', to: 'dashboard#index', as: :dashboard

  # 💳 4. Stripe payment flows (CSRF safe)
  post '/pay', to: 'payments#create'
  get '/success', to: 'payments#success'
  get '/cancel', to: 'payments#cancel'

  # 📄 5. PUBLIC Batch APIs + PDFs (NO AUTH REQUIRED)
  resources :batches, only: [] do
    member do
      get :demo                    # /batches/123456/demo → JSON
      get :public_pdf, defaults: { format: :pdf }    # /batches/123456/public_pdf.pdf
      get :chain_of_custody, defaults: { format: :pdf }  # /batches/123456/chain_of_custody.pdf
    end
  end

  # 🚣 6. TENANT-SCOPED routes (AUTH REQUIRED)
  authenticate :user do
    namespace :tenant_scope do
      resources :batches
      resources :tenants
      resources :shipments
    end
  end

  # 🌐 7. Webhooks (no CSRF protection)
  post '/webhooks/stripe', to: 'webhooks#stripe'

  # 📊 8. Legacy PDF + Reports
  get '/pdf', to: 'pdf_reports#show'
  get '/reports/compliance', to: 'reports#compliance'

  # 🛰️ 9. Public GPS + Health APIs
  namespace :api do
    namespace :v1 do
      resources :gps, only: [:index, :show]
      resources :health, only: [:index]
      resources :telemetry, only: [:index, :show]
    end
  end

  # 🛠️ 10. Debug endpoints (remove in prod)
  get '/debug/zeitwerk', to: proc { 
    Rails.application.eager_load!
    [200, {}, ['Zeitwerk loader OK']]
  }
end
