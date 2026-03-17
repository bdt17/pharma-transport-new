require_relative "boot"
require "rails/all"
Bundler.require(*Rails.groups)

module PharmaTransport
  class Application < Rails::Application
    config.load_defaults 7.1
    config.api_only = false
  end
end
