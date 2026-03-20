class User < ApplicationRecord
  # Core Devise modules
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, 
         :timeoutable, :trackable

  # 21 CFR §11.300 - Two Factor Authentication (MFA)
  devise :two_factor_authenticatable, :two_factor_backupable, :otp_encryptable
  
  # Pharma-specific validations
  validates :email, presence: true, uniqueness: true
  validates :name, presence: true, length: { maximum: 100 }
  
  # 21 CFR §11.10(b) - Strong passwords for pharma users
  validate :password_complexity

  # User profile for pharma transport
  has_many :shipments
  has_many :organizations

  def after_database_authentication
    super
    configure_two_factor
  end

  def configure_two_factor
    unless otp_secret_key
      self.otp_secret_key = ROTP::SecretKey.base32
      save!
    end
  end

  def qr_code_url
    issuer = 'PharmaTransport'
    label = "#{issuer}:#{email}"
    "otpauth://totp/#{label}?secret=#{otp_secret_key}&issuer=#{issuer}"
  end

  private

  def password_complexity
    return if password.blank? || password&.match?(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$/)
    errors.add :password, "must be 8+ characters with uppercase, lowercase, and number (21 CFR §11.300)"
  end
end
