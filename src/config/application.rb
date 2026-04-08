require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PharmaTemp
  class Application < Rails::Application
    # 🚨 FIXED: Rails 7.1.6 compatibility (was 8.1)
    config.load_defaults 7.1

    # Configuration for the application, engines, and railties goes here.
    config.time_zone = "Mountain Time (US & Canada)"  # Phoenix AZ
    config.active_record.default_timezone = :utc

    # 🛡️ Security: Force HTTPS in production
    config.force_ssl = Rails.env.production?

    # 📱 API-first (pharma SaaS)
    config.api_only = false

    # ⚡ Performance
    config.cache_store = :redis_cache_store, { url: ENV['REDIS_URL'] || 'redis://localhost:6379/1' }
    
    # 🚀 Background jobs (Sidekiq)
    config.active_job.queue_adapter = :sidekiq

    # 📄 Generators
    config.generators.system_tests = nil
    config.generators.assets = false
    config.generators.helper = false

    # 🧹 Ignore lib subdirs (safe defaults)
    config.autoload_lib(ignore: %w[assets tasks generators middleware templates])

    # 💎 Custom pharma compliance initializer
    config.to_prepare do
      # Tenant scoping for multi-tenant pharma logistics
      # Add tenant-aware concerns here
    end
  end
end
