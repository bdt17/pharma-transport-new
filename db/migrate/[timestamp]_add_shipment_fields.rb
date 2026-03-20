class AddShipmentFields < ActiveRecord::Migration[7.1]
  def change
    add_column :shipments, :status, :string, null: false, default: 'PENDING'
    add_column :shipments, :biologics, :string
    add_column :shipments, :route, :string
    add_column :shipments, :temperature, :string
    add_column :shipments, :audit_trail, :text
  end
end
