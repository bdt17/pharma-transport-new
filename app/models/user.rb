# app/models/user.rb

class User < ApplicationRecord
  # For now: no Devise; just local validation
  validates :password, presence: true, on: :create
  validate :password_complexity

  private

  def password_complexity
    return if password.blank?

    unless password.length >= 12 &&
           password.match?(/[a-z]/) &&
           password.match?(/[A-Z]/) &&
           password.match?(/\\d/) &&
           password.match?(/[^a-zA-Z0-9]/)
      errors.add :password,
        "must be at least 12 characters, with lowercase, uppercase, digit, and special character"
    end
  end
end
