Rails.application.configure do
  config.cache_classes = true
  config.eager_load = false
  config.consider_all_requests_local = false
  
  config.public_file_server.enabled = true
  config.log_level = :warn
  config.logger = ActiveSupport::Logger.new(STDOUT)
  
  config.force_ssl = true
  config.hosts << ".onrender.com"
end
