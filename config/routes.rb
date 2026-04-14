# config/routes.rb

Rails.application.routes.draw do
  # 🩺 1. Health checks
  get "up"     => "rails/health#show",   as: :rails_health_check
  get "/health" => "health#show",        as: :health_check

  # 🔐 2. Devise authentication (temporarily disabled)
  # devise_for :users, controllers: {
  #   registrations: "users/registrations",
  #   sessions:      "users/sessions"
  # }

  # 🏠 3. Public landing + dashboard
  root "home#index"
  get "/dashboard", to: "dashboard#index", as: :dashboard

  # 💳 4. Stripe payment flows (CSRF safe)
  post "/pay",    to: "payments#create"
  get  "/success", to: "payments#success"
  get  "/cancel",  to: "payments#cancel"

  # 📄 5. PUBLIC Batch APIs + PDFs (NO AUTH REQUIRED)
  resources :batches, only: [] do
    member do
      get :demo
      get :public_pdf,         defaults: { format: :pdf }
      get :chain_of_custody,   defaults: { format: :pdf }
    end
  end

  # 🌐 7. Webhooks (no CSRF protection)
  post "/webhooks/stripe", to: "webhooks#stripe"

  # 📊 8. Legacy PDF + Reports
  get "/pdf",                         to: "pdf_reports#show"
  get "/reports/compliance",          to: "reports#compliance"

  # 🛰️ 9. Public GPS + Health APIs
  namespace :api do
    namespace :v1 do
      resources :gps,      only: [:index, :show]
      resources :health,   only: [:index]
      resources :telemetry, only: [:index, :show]
    end
  end

  # 🚣 6. TENANT-SCOPED routes (AUTH REQUIRED — disabled for now)
  # authenticate :user do
  #   namespace :tenant_scope do
  #     resources :batches
  #     resources :tenants
  #     resources :shipments
  #   end
  # end

  # 🛠️ 10. Debug endpoints (remove in prod)
  get "/debug/zeitwerk", to: proc {
    Rails.application.eager_load!
    [200, {}, ["Zeitwerk loader OK"]]
  }
end
