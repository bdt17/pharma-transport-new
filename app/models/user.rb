class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, 
         :two_factor_authenticatable, :two_factor_backupable
end
