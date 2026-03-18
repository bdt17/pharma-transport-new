Rails.application.routes.draw do
  root "home#index"
  
  # AUTH
  get "login", to: "sessions#new", as: :login
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout
  
  # PDF (CRITICAL)
  get "pdf-health", to: "home#pdf_health"
  get "pdf/chain-of-custody", to: "pdf#chain_of_custody", as: :chain_of_custody_pdf
  
  # LEADS
  post "lead_capture", to: "leads#create"
end
