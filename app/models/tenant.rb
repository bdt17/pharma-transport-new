class Tenant < ApplicationRecord
  has_many :batches, dependent: :destroy

  validates :name, :subdomain, presence: true

  def to_param
    subdomain
  end
end
