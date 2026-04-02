module SetCurrentTenant
  extend ActiveSupport::Concern

  included do
    before_action :set_current_tenant_from_subdomain
    helper_method :current_tenant
  end

  private

  def set_current_tenant_from_subdomain
    subdomain = request.subdomain
    return unless subdomain.present? && subdomain != "www"

    tenant = Tenant.find_by(subdomain: subdomain)
    Current.tenant = tenant
  end

  def current_tenant
    Current.tenant
  end
end
