class AuditLog < ApplicationRecord
  belongs_to :user
  belongs_to :batch
  belongs_to :tenant
end
