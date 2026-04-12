require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # Mailer
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { 
    host: ENV['APP_HOST'] || 'pharma-transport-new.onrender.com'
  }

  # HTTPS
  config.force_ssl = true

  # Logger FIXED
  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = ::Logger::Formatter.new
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  config.log_tags  = [ :request_id ]
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Safe logger level
  config.logger&.level = Logger::WARN if config.logger && Rails.env.production?

  # Assets
  # Assets - Rails 7 Importmap/Tailwind
config.public_file_server.enabled = true
config.public_file_server.headers = {
  'Cache-Control' => "public, max-age=#{1.year.to_i}, immutable"
}
  # Storage
  config.active_storage.service = :local

  # Cache
  config.cache_store = :memory_store

  # Jobs
  config.active_job.queue_adapter = :inline

  # Hosts
  config.hosts << "pharma-transport-new.onrender.com"

  config.active_support.report_deprecations = false

  config.active_record.dump_schema_after_migration = false
  config.active_record.verbose_query_logs = false

  config.silence_healthcheck_path = "/health"
end
