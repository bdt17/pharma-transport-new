#!/bin/bash
set -e

echo "=== Pharma SaaS Nuclear Deploy ==="

bundle config set path 'vendor/bundle' --local
bundle config set without 'development test' --local
bundle install

echo "⚡ Assets..."
rm -rf public/assets tmp/cache/assets
SECRET_KEY_BASE=${SECRET_KEY_BASE:-$(bin/rails secret)} RAILS_ENV=production bundle exec rails assets:precompile

echo "🧪 Nuclear seed batch 123456..."
RAILS_ENV=production bin/rails runner "
begin
  tenant = Tenant.first || Tenant.create!(name: 'Demo Tenant')
  Batch.delete_all(id: 123456) rescue nil
  Batch.create!(
    id: 123456,
    tenant_id: tenant.id,
    batch_id: 'DEMO-123456',
    product: 'Insulin Vials 21CFR',
    status: 'in_transit',
    temp: '2°C',
    location: 'PHX Drone'
  )
  puts '✅ Batch 123456 created!'
rescue => e
  puts "Seed error: #{e.message}"
end
"

echo "=== Deploy ready ==="
