class AddFieldsToShipments < ActiveRecord::Migration[7.1]
  def change
    # Only add if columns don't exist (safe migration)
    add_column :shipments, :status, :string, default: 'PENDING' unless column_exists?(:shipments, :status)
    add_column :shipments, :biologics, :string unless column_exists?(:shipments, :biologics)
    add_column :shipments, :route, :string unless column_exists?(:shipments, :route)
    add_column :shipments, :temperature, :string unless column_exists?(:shipments, :temperature)
    add_column :shipments, :audit_trail, :text unless column_exists?(:shipments, :audit_trail)
  end
end
