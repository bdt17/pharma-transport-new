#!/bin/bash
# script/seed_pharma_data.sh - Production‑ready pharma demo data

echo "🌱 Seeding Thomas IT Pharma data..."

bin/rails runner "
# Create tenants
tenants_data = [
  { name: 'Banner Pharma', subdomain: 'banner' },
  { name: 'Demo Lab', subdomain: 'demo' },
  { name: 'Thomas IT', subdomain: 'thomasit' }
]

tenants_data.each do |data|
  tenant = Tenant.find_or_create_by(subdomain: data[:subdomain]) do |t|
    t.name = data[:name]
  end
  puts \"Created tenant: #{tenant.name} (#{tenant.subdomain})\"
end

# Add pharma batches to banner tenant
banner_tenant = Tenant.find_by(subdomain: 'banner')
5.times do |i|
  Batch.create!(
    tenant: banner_tenant,
    lot: \"LOT-#{Time.now.to_i + i}\",
    product_type: %w[Insulin Vaccine Biologics][i % 3],
    status: %w[in_transit delivered issue][i % 3],
    batch_id: \"BATCH-#{Time.now.to_i + i}\",
    product: %w[Humalog Pfizer Moderna][i % 3],
    temp: \"2-8°C\",
    location: \"Phoenix AZ\"
  )
end

puts \"✅ Seeded #{Tenant.count} tenants + #{Batch.count} batches\"
"
