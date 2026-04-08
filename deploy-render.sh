#!/bin/bash
echo "🚀 PHARMA TRANSPORT - AUTO DEPLOY v2.2 (Phase 12 Fixed)"

# 0. SECRET_KEY_BASE preserved
echo "🔑 SECRET_KEY_BASE: ${SECRET_KEY_BASE:0:10}... (${#SECRET_KEY_BASE} chars)"
[ -z "$SECRET_KEY_BASE" ] && echo "⚠️ Add SECRET_KEY_BASE to Render env"

# 1. Clean precompile
echo "⚡ Precompiling assets..."
rm -rf public/assets tmp/cache/assets
SECRET_KEY_BASE=${SECRET_KEY_BASE:-$(bin/rails secret)} RAILS_ENV=production bundle exec rails assets:precompile

# 2. Migrations
echo "🗄️ Migrations..."
RAILS_ENV=production bundle exec rails db:migrate

# 3. SINGLE idempotent seed (nukes 123456 + recreate)
echo "🌱 Seeding demo batch 123456 (PK safe)..."
RAILS_ENV=production bin/rails runner "
# Nuke PK conflict (SQLite safe)
ActiveRecord::Base.connection.execute('DELETE FROM batches WHERE id = 123456') rescue nil
ActiveRecord::Base.connection.execute('UPDATE sqlite_sequence SET seq = 123455 WHERE name = \"batches\"') rescue nil
Batch.connection.schema_cache.clear!
ActiveRecord::Base.clear_active_connections!

tenant = Tenant.first || Tenant.create!(name: 'Thomas IT Demo', subdomain: 'demo')
product = Product.first || Product.create!(name: 'Insulin Vials', sku: 'INS-001')

Batch.find_or_create_by!(id: 123456, batch_id: 'DEMO-123456') do |b|
  b.tenant = tenant
  b.product = product
  b.status = 'in_transit'
  b.temp = '2-8°C'
  b.location = 'Phoenix → LAX Drone (21 CFR)'
end
puts '✅ Batch 123456 + tenant/product seeded!'
"

# 4. Commit & push
echo "🧹 Git..."
git add public/assets/ config/environments/production.rb db/schema.rb
git commit -m "deploy: assets+migrate+batch123456 $(date)" || true
git push origin main

echo "🎉 DEPLOY COMPLETE! https://pharma-transport-new.onrender.com/"
echo "📄 PDF: https://pharma-transport-new.onrender.com/batches/123456/chain_of_custody.pdf"
