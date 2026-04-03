# Gemfile
source 'https://rubygems.org'
ruby '3.2.2'

gem 'rails', '~> 8.1.3'
gem 'puma'
gem 'pg'                       # Production PostgreSQL
gem 'sprockets-rails'
gem 'bootsnap', require: false
gem 'stripe', '~> 10.0'
gem 'prawn', '~> 2.4'          # 21 CFR PDF generator
gem 'sidekiq'

gem 'devise', '~> 5.0'
gem 'devise-two-factor', '~> 6.4'  # MFA for pharma compliance

# Tailwind CSS (production-ready; works with Sprockets pipeline)
gem 'tailwindcss-rails', '~> 2.0'

group :development, :test do
  gem 'sqlite3', '~> 1.4'      # Local development only
  gem 'debug', '~> 1.9'        # Rails console debugging
end

group :development do
  gem 'web-console'
end

group :test do
  gem 'rspec-rails'
end

gem 'rqrcode'
