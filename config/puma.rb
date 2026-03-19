# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is "0, 5"

max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
port        ENV.fetch("PORT") { 3000 }

# Specifies the `environment` that Puma will run in.
environment ENV.fetch("RAILS_ENV") { "production" }

# Use multiple worker processes to serve requests, recommended for Rails apps
# Render sets WEB_CONCURRENCY automatically
workers ENV.fetch("WEB_CONCURRENCY") { 1 }

# Use short timeouts for cold starts (Render free tier)
worker_timeout 60

# FIX: Silence Render's single worker warning
silence_single_worker_warning true

# Preload app for better memory usage
preload_app!

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart
