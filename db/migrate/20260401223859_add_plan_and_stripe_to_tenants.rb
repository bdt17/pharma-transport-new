class AddPlanAndStripeToTenants < ActiveRecord::Migration[7.1]
  def change
    add_column :tenants, :plan, :integer
    add_column :tenants, :stripe_id, :string
    add_index :tenants, :stripe_id
  end
end
