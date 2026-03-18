require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"

Bundler.require(:default, ENV.fetch('RAILS_ENV') { 'development' }, __FILE__)

module PharmaTransportClean
  class Application < Rails::Application
    config.load_defaults 7.1
    config.api_only = false
    
    # No custom initializers = no circular deps
  end
end
