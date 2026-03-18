Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES']
  
  config.log_level = :warn
  config.logger = ActiveSupport::Logger.new(STDOUT)
  
  config.action_mailer.perform_caching = false
  config.active_record.sqlite3_production_warning = false
  config.active_job.queue_adapter = :inline
  config.force_ssl = true
  
  config.hosts << ".onrender.com"
end
