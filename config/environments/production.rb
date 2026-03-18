Rails.application.configure do
  # Core settings
  config.cache_classes = true
#  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # Logging
  config.log_level = :info

  # Static assets
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{1.hour.to_i}"
  }

  # Don't digest assets (Render handles)
  config.assets.compile = false
  config.assets.digest = true

  # Render.com hosts
  config.hosts << "pharma-transport-new.onrender.com"
  config.hosts << ".onrender.com"

  # Security
  config.force_ssl = true  # Optional, if using Render's HTTPS

  # Mailer (if needed)
  config.action_mailer.default_url_options = { host: 'pharma-transport-new.onrender.com' }
end
