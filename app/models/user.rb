class User < ApplicationRecord
  devise :two_factor_authenticatable
  devise :registerable,
         :recoverable, :rememberable, :validatable
end
