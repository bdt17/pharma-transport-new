require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module PharmaTransportClean
  class Application < Rails::Application
    config.load_defaults 7.1
    
    # Minimal config - no custom railties
    config.active_record.async_query_executor = :global_thread_pool
  end
end
