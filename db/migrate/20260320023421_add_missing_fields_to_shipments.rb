class AddMissingFieldsToShipments < ActiveRecord::Migration[7.1]
  def change
    add_column :shipments, :status, :string, default: 'PENDING', null: false
    add_column :shipments, :biologics, :text
    add_column :shipments, :route, :text
    add_column :shipments, :temperature, :string
    add_column :shipments, :audit_trail, :text
  end
end
