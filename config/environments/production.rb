Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  config.log_level = :info
  config.log_tags = [ :request_id ]

  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    "Cache-Control" => "public, max-age=#{1.hour.to_i}"
  }

  # config.assets.compile = false   ← deleted
  # config.assets.digest = true     ← deleted

  config.hosts << "pharma-transport-new.onrender.com"
  config.hosts << ".onrender.com"

  config.force_ssl = false

  config.action_mailer.default_url_options = {
    host: "pharma-transport-new.onrender.com",
    protocol: "https"
  }
  config.action_mailer.asset_host = "https://pharma-transport-new.onrender.com"
end
