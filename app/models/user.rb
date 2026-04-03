class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :two_factor_authenticatable,
         otp_secret_encryption_key: ENV['OTP_SECRET_ENCRYPTION_KEY']

  validates :password, presence: true, on: :create
  validate :password_complexity

  private

  def password_complexity
    return if password.blank?

    unless password.length >= 12 &&
           password.match?(/[a-z]/) &&
           password.match?(/[A-Z]/) &&
           password.match?(/\d/) &&
           password.match?(/[^a-zA-Z0-9]/)
      errors.add :password,
        "must be at least 12 characters, with lowercase, uppercase, digit, and special character"
    end
  end
end
