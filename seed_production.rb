# Render Postgres safe seed
tenant = Tenant.first || Tenant.create!(name: 'Thomas IT Demo', subdomain: 'demo')
product = Product.first || Product.create!(name: 'Insulin Vials', sku: 'INS-001')

ActiveRecord::Base.connection.execute('DELETE FROM batches WHERE id = 123456') rescue nil
ActiveRecord::Base.connection.execute('ALTER SEQUENCE IF EXISTS batches_id_seq RESTART WITH 123457') rescue nil
Batch.connection.schema_cache.clear!

Batch.create!(
  id: 123456,
  batch_id: 'DEMO-123456',
  tenant: tenant,
  product: product,
  status: 'in_transit',
  temp: '2-8°C',
  location: 'Phoenix AZ → LAX Drone (21 CFR Part 11)'
)
puts "✅ PRODUCTION batch 123456 LIVE!"
