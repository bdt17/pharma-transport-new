# Puma config for Render
port        ENV['PORT']     || 3000
host        ENV['HOST']     || '0.0.0.0'
workers     ENV.fetch("WEB_CONCURRENCY") { 1 }
threads     1, 5
environment ENV.fetch("RAILS_ENV") { "production" }

preload_app!

plugin :tmp_restart
