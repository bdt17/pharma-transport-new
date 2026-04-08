class Tenant < ApplicationRecord
  has_many :batches, dependent: :destroy

  validates :name, :subdomain, presence: true

  def to_param
    subdomain
  end

  def subdomain_url
    "#{subdomain}.#{ENV['APP_DOMAIN'] || 'lvh.me:3000'}"
  end
end
