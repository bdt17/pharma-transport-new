# Puma for Render (no preload - fixes crash)
environment ENV.fetch("RAILS_ENV") { "development" }
port        ENV.fetch("PORT") { 3000 }
workers     ENV.fetch("WEB_CONCURRENCY") { 1 }

threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count

# NO preload_app! - fixes Render crash
# plugin :tmp_restart

on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end
