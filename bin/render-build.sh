#!/bin/bash
set -e

echo "=== Pharma SaaS Build (Batch 123456) ==="

bundle config set path 'vendor/bundle' --local
bundle config set without 'development test' --local
bundle install

rm -rf public/assets tmp/cache/assets
SECRET_KEY_BASE=${SECRET_KEY_BASE:-$(bin/rails secret)} RAILS_ENV=production bundle exec rails assets:precompile

echo "🌱 Seeding batch 123456..."
RAILS_ENV=production bin/rails runner "
tenant = Tenant.first || Tenant.create!(name: 'Thomas IT Demo', subdomain: 'demo')
Batch.find_or_create_by!(id: 123456, tenant_id: tenant.id) do |b|
  b.batch_id = 'DEMO-123456'
  b.product = 'Insulin Vials (21 CFR Part 11)'
  b.status = 'in_transit'
  b.temp = '2-8°C'
  b.location = 'Phoenix → LAX Drone Fleet'
end
puts '✅ Batch 123456 LIVE - Chain of Custody PDFs ready!'
"

echo "=== Build complete ==="
