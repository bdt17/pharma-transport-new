# script/seed_pharma_data.rb - Match your actual Batch schema

puts "🌱 Seeding Thomas IT Pharma data..."

# Create tenants (already done)
tenants_data = [
  { name: "Banner Pharma", subdomain: "banner" },
  { name: "Demo Lab", subdomain: "demo" },
  { name: "Thomas IT", subdomain: "thomasit" }
]

tenants_data.each do |data|
  tenant = Tenant.find_or_create_by(subdomain: data[:subdomain]) do |t|
    t.name = data[:name]
  end
  puts "Tenant: #{tenant.name} (#{tenant.subdomain})"
end

# Add pharma batches using YOUR ACTUAL columns
banner_tenant = Tenant.find_by(subdomain: "banner")
5.times do |i|
  Batch.create!(
    tenant: banner_tenant,
    batch_id: "BATCH-#{Time.now.to_i + i}",
    product: "Humalog #{i+1}",
    status: %w[in_transit delivered issue][i % 3],
    temp: "2-8°C",
    location: "Phoenix AZ"
  )
end

puts "✅ Seeded #{Tenant.count} tenants + #{Batch.count} batches"
