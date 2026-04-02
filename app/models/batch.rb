class Batch < ApplicationRecord
  belongs_to :tenant
  validates :batch_id, :product, :status, presence: true
  validates :tenant, presence: true

  scope :recent, -> { order(created_at: :desc) }

  # Prevent accidental cross-tenant writes
  validate :tenant_must_not_change, on: :update

  def tenant_must_not_change
    if tenant_id_changed? && tenant_id_was.present?
      errors.add(:tenant, "cannot be changed once set")
    end
  end

  def status_icon
    { 'in_transit' => '🚚', 'delivered' => '✅', 'issue' => '⚠️' }[status] || '⏳'
  end
end
