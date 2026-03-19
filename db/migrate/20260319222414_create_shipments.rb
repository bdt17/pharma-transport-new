class CreateShipments < ActiveRecord::Migration[7.1]
  def change
    create_table :shipments do |t|
      t.string :shipment_id
      t.string :status
      t.text :biologics
      t.string :origin
      t.string :destination
      t.string :temperature

      t.timestamps
    end
  end
end
