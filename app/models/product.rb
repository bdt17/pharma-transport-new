class Product < ApplicationRecord
  belongs_to :tenant
  validates :name, :sku, :cold_chain_temp_min, :cold_chain_temp_max, presence: true
  validates :sku, uniqueness: { scope: :tenant_id }

  scope :recent, -> { order(created_at: :desc) }
  scope :cold_chain, -> { where('cold_chain_temp_max > 0') }

  validate :tenant_must_not_change, on: :update

  def tenant_must_not_change
    if tenant_id_changed? && tenant_id_was.present?
      errors.add(:tenant, "cannot be changed (21 CFR audit)")
    end
  end

  def status_icon
    cold_chain? ? '🧊' : '💊'
  end

  def cold_chain?
    cold_chain_temp_max.positive?
  end

  def temp_range
    "#{cold_chain_temp_min}°C - #{cold_chain_temp_max}°C"
  end

  before_create :set_audit_hash
  def set_audit_hash
    self.audit_hash ||= Digest::SHA256.hexdigest("#{sku}-#{Time.current.utc}")
  end
end
