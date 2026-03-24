Rails.application.routes.draw do
  root "application#index"
  
  get "/batches", to: proc { 
    [200, {"Content-Type" => "text/plain"}, ["Batches page coming soon..."]]
  }
  
  get "/health", to: proc { 
    [200, {"Content-Type" => "application/json"}, 
     [{ok: true, service: "pharma-transport", ts: Time.now.utc.iso8601}.to_json]]
  }
end
