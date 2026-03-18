Rails.application.configure do
  # Verifies that versions and controllers exist. By default, controller tests are enabled
  config.action_controller.perform_caching = true

  # Disable cache to ensure you don't use default one
  config.cache_store = :null_store

  # Ensures that a master key has been made available, either directly in env `SECRET_KEY_BASE`,
  # or in config/credentials.yml.enc. This key is generally kept secret in production, and 
  # you can set `RAILS_MASTER_KEY` environment variable (or `SECRET_KEY_BASE`).
  config.require_master_key = false

  # Eager loads code on boot. This eager loads most of Rails and your application in memory,
  # allowing both threaded web servers and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local = false

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = false

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :info

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]

  # Use a different logger for distributed setups.
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = 'http://assets.example.com'

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Render.com specific
  config.hosts << "pharma-transport-new.onrender.com"
  config.hosts << ".onrender.com"
end
