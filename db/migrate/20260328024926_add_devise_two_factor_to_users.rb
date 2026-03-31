class AddDeviseTwoFactorToUsers < ActiveRecord::Migration[7.1]
  def change
    # These columns already exist; do nothing.
    #
    # Commented out so they don’t cause "duplicate column name":
    # add_column :users, :otp_secret, :string
    # add_column :users, :consumed_timestep, :integer

    # Add *only* if they don’t exist (just being defensive):
    add_column :users, :encrypted_otp_secret,  :string unless column_exists?(:users, :encrypted_otp_secret)
    add_column :users, :otp_backup_codes,      :text   unless column_exists?(:users, :otp_backup_codes)
    add_column :users, :otp_required_for_login, :boolean, default: true, null: false unless column_exists?(:users, :otp_required_for_login)
  end
end
