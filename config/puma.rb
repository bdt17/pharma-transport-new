# Puma can serve each request in a thread from an internal thread pool.
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# Render PORT
port        ENV.fetch("PORT") { 3000 }

# Production
environment ENV.fetch("RAILS_ENV") { "production" }

# Render workers
workers ENV.fetch("WEB_CONCURRENCY") { 1 }

# Timeouts
worker_timeout 60
worker_shutdown_timeout 30

# FIX: Puma 6.6+ syntax - set before workers
@options[:silence_single_worker_warning] = true

# Preload app
preload_app!

# Allow restart
plugin :tmp_restart
