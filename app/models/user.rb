class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validate :password_complexity

  private

  def password_complexity
    return if password.blank?
    unless password.match?(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
      errors.add :password, "must include at least one lowercase, one uppercase, and one digit"
    end
  end
end
