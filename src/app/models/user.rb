class User < ApplicationRecord
  devise :database_authenticatable, :rememberable, :trackable, :validatable

  # Optional: add a friendly display name
  def to_s
    name.presence || email.presence || "User ##{id}"
  end
end
