#!/bin/bash
set -e

echo "=== Pharma SaaS (Safe Precompile) ==="

bundle config set path 'vendor/bundle' --local
bundle config set without 'development test' --local
bundle install

echo "⚡ Assets only (no seed)..."
rm -rf public/assets tmp/cache/assets
SECRET_KEY_BASE=${SECRET_KEY_BASE:-$(bin/rails secret)} RAILS_ENV=production bundle exec rails assets:precompile

echo "=== Build safe ==="
