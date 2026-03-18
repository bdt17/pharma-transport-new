Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  config.active_storage.service = :local

  config.log_level = :info

  # ✅ FIXED LOGGER
  config.logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
  config.log_tags = [ :request_id ]

  config.action_mailer.perform_caching = false
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.active_record.sqlite3_production_warning = false

  config.active_job.queue_adapter = :inline

  config.force_ssl = true

  config.hosts << "render.com"
end
