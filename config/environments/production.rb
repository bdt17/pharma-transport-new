Rails.application.configure do
  config.eager_load = true
  
  # SERVE STATIC ASSETS
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{1.hour.to_i}"
  }
  
  # Render.com
  config.hosts << "pharma-transport-new.onrender.com"
  config.hosts << ".onrender.com"
end
