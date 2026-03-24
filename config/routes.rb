Rails.application.routes.draw do
  root "pages#index"
  
  # Dashboard + Batch routes (NEW)
  get '/batches', to: 'batches#index', as: :batches
  get '/batches/:id', to: 'batches#show', as: :batch
  get '/batches/:id/chain-of-custody.pdf', to: 'batches#show', as: :batch_pdf
  
  # Health check (KEEP)
  get "/health", to: proc {
    [200, {"Content-Type" => "application/json"},
     [{ok: true, service: "pharma-transport", ts: Time.now.utc.iso8601}.to_json]]
  }
end
