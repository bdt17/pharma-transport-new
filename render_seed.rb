ActiveRecord::Base.connection.execute("DELETE FROM batches WHERE id = 123456")
ActiveRecord::Base.connection.execute("UPDATE sqlite_sequence SET seq = 123455 WHERE name = 'batches'")

tenant = Tenant.first || Tenant.create!(name: 'Thomas IT Demo')
Batch.create!(
  id: 123456,
  batch_id: 'DEMO-123456',
  tenant: tenant,
  product: 'Insulin',
  status: 'In Transit',
  temp: '2°C',
  location: 'Phoenix'
)
puts '✅ Render batch OK'
