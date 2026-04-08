#!/bin/bash
set -e

echo "=== render-build.sh: starting (Pharma SaaS Phase 12) ==="

# Bundler config (fixes deprecation)
bundle config set path 'vendor/bundle'
bundle config set without 'development test'
bundle config set deployment 'true'

# Install
echo "Installing gems..."
bundle install

# Assets
echo "⚡ Precompiling assets..."
rm -rf public/assets tmp/cache/assets
SECRET_KEY_BASE=${SECRET_KEY_BASE:-$(bin/rails secret)} RAILS_ENV=production bundle exec rails assets:precompile

# **SEED batch 123456**
echo "🌱 Seeding demo batch 123456 (Postgres safe)..."
RAILS_ENV=production bin/rails runner "
tenant = Tenant.first || Tenant.create!(name: 'Thomas IT Demo', subdomain: 'demo')
product = Product.first || Product.create!(name: 'Insulin Vials', sku: 'INS-001')

ActiveRecord::Base.connection.execute('DELETE FROM batches WHERE id = 123456') rescue nil
ActiveRecord::Base.connection.execute('ALTER SEQUENCE IF EXISTS batches_id_seq RESTART WITH 123457') rescue nil
Batch.connection.schema_cache.clear!

Batch.find_or_create_by!(id: 123456, batch_id: 'DEMO-123456') do |b|
  b.tenant_id = tenant.id
  b.product_id = product.id
  b.status = 'in_transit'
  b.temp = '2-8°C'
  b.location = 'Phoenix → LAX Drone (21 CFR Part 11)'
end
puts '✅ PRODUCTION batch 123456 + tenant/product LIVE!'
"

echo "=== render-build.sh: done ==="
