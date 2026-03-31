class CreateBatches < ActiveRecord::Migration[7.1]
  def change
    create_table :batches do |t|
      t.string :batch_id
      t.string :product
      t.string :status
      t.string :temp
      t.string :location

      t.timestamps
    end
  end
end
