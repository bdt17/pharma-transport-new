class AddTenantToBatch < ActiveRecord::Migration[7.1]
  def change
    add_reference :batches, :tenant, null: false, foreign_key: true
  end
end
