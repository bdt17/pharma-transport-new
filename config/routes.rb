Rails.application.routes.draw do
  # 1. Health (ALWAYS first for Render)
  get '/health', to: proc { [200, {}, ['OK']] }
  
  # 2. Devise (ALWAYS second)
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions:      'users/sessions'
  }
  
  # 3. Public routes
  root 'home#index'
  get '/dashboard', to: 'dashboard#index', as: :dashboard
  
  # 4. Stripe (CSRF safe)
  post '/pay', to: 'payments#create'
  get '/success', to: 'payments#success'
  get '/cancel', to: 'payments#cancel'
  
  # 5. PUBLIC Batch APIs (no auth)
  resources :batches, only: [] do
    member do
      get :demo           
      get :public_pdf, defaults: { format: :pdf }
      get :chain_of_custody, defaults: { format: :pdf }
    end
  end
  
  # 6. TENANT-SCOPED (auth required)
  authenticate :user do  # ← ADD: Only load for logged-in users
    namespace :tenant_scope do
      resources :batches
      resources :tenants
    end
  end
  
  # 7. Webhooks (no CSRF)
  post '/webhooks/stripe', to: 'webhooks#stripe'
  
  # 8. Legacy + API
  get '/pdf', to: 'pdf_reports#show'
  get '/reports/compliance', to: 'reports#compliance'
  
  namespace :api do
    resources :gps, only: [:index, :show]
    resources :health, only: [:index]
  end
end
