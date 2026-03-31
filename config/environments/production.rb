# config/environments/production.rb
Rails.application.configure do
  # Core settings
  config.cache_classes = true
  config.eager_load = false    # ← this avoids eager‑load crash on startup
  config.consider_all_requests_local = true  # ← show full exception backtrace in 500
  config.action_controller.perform_caching = true

  # Logging
  config.log_level = :debug    # ← more details in Render logs

  # Static assets
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{1.hour.to_i}"
  }

  # Don't let Rails compile assets in production (Render already precompiled)
  config.assets.compile = false
  config.assets.digest = true

  # Render.com hosts
  config.hosts << "pharma-transport-new.onrender.com"
  config.hosts << ".onrender.com"

  # Allow localhost / 127.0.0.1 for local production debug
  config.hosts << "localhost"
  config.hosts << "127.0.0.1"

  # Security
  config.force_ssl = false    # ← disable SSL forcing until you own the domain

  # Mailer
  config.action_mailer.default_url_options = { host: 'pharma-transport-new.onrender.com' }
end
