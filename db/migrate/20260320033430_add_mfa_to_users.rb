class AddMfaToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :encrypted_otp_secret, :string
    add_column :users, :otp_backup_codes, :text
    add_column :users, :consumed_timestep, :integer
  end
end
