#!/bin/bash
set -e

echo "=== render-build.sh: starting ==="

# Install gems
echo "Installing Ruby gems..."
bundle lock --add-platform x86_64-linux
bundle install -j4 --retry 3 --path vendor/bundle

# Precompile assets
echo "Precompiling assets..."
rm -rf public/assets tmp/cache/assets
SECRET_KEY_BASE=${SECRET_KEY_BASE:-$(bin/rails secret)} RAILS_ENV=production bundle exec rails assets:precompile

# **SEED HERE** (Render Postgres safe)
echo "🌱 Seeding demo batch 123456..."
RAILS_ENV=production bin/rails runner "
tenant = Tenant.first || Tenant.create!(name: 'Thomas IT Demo', subdomain: 'demo')
product = Product.first || Product.create!(name: 'Insulin Vials', sku: 'INS-001')

# Force ID 123456 (Postgres serial safe)
ActiveRecord::Base.connection.execute('DELETE FROM batches WHERE id = 123456') rescue nil
Batch.connection.execute('ALTER SEQUENCE batches_id_seq RESTART WITH 123457') rescue nil

Batch.find_or_create_by!(id: 123456, batch_id: 'DEMO-123456') do |b|
  b.tenant = tenant
  b.product = product
  b.status = 'in_transit'
  b.temp = '2-8°C'
  b.location = 'Phoenix → LAX Drone (21 CFR)'
end
puts '✅ Batch 123456 + tenant/product seeded for PDFs!'
"

echo "=== render-build.sh: done ==="
