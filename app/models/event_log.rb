class EventLog < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :batch, optional: true
  belongs_to :tenant, optional: true

  validates :action, presence: true

  after_initialize :set_defaults

  private

  def set_defaults
    self.tenant ||= Current.tenant if Current.tenant
  end
end
