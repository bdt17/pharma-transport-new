class CreateEventLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :event_logs do |t|
      t.string :action
      t.references :user, null: false, foreign_key: true
      t.references :batch, null: false, foreign_key: true
      t.references :tenant, null: false, foreign_key: true
      t.text :metadata

      t.timestamps
    end
  end
end
