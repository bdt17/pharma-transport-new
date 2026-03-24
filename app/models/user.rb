class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  # Basic Devise for pharma users
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  # Pharma profile
  validates :email, presence: true, uniqueness: true
  validates :name, presence: true, length: { maximum: 100 }

  has_many :shipments

  # 21 CFR §11.10(d) - Limited access tracking
  def last_sign_in_ip
    current_sign_in_ip
  end
end
