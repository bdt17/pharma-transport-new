Rails.application.routes.draw do
  root "pages#index"
  
  resources :batches, only: [:index, :show] do
    member do
      get :chain_of_custody, path: 'chain-of-custody', defaults: {format: 'pdf'}
    end
  end
  
  get "/health", to: proc { 
    [200, {"Content-Type" => "application/json"}, [{ok: true, service: "pharma-transport", ts: Time.now.utc.iso8601}.to_json]] 
  }
end
