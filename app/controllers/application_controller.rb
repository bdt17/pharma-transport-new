class ApplicationController < ActionController::Base
  # Devise: Redirect after login
  def after_sign_in_path_for(resource)
    dashboard_path
  end

   private

  def protect_from_forgery
    super(prepend: true, with: :exception)
  end

  # Health endpoint (Render.com)
  def health
    head :ok
  end

  # Multi-tenant: Current tenant (subdomain/account)
  def current_tenant
    # Production: Tenant.find_by(subdomain: request.subdomain)
    # Phase 11 dev: Stub first tenant (single-tenant mode)
    @current_tenant ||= Tenant.first || Tenant.create!(name: 'Thomas IT Demo', subdomain: 'demo')
  end
  helper_method :current_tenant

  # Devise: Current user
  def current_user
    @current_user ||= super
  end
  helper_method :current_user

  # Tenant-scoped queries (batches, reports, etc.)
  def current_tenant_scope
    if current_tenant
      { tenant: current_tenant }
    else
      {}
    end
  end
  helper_method :current_tenant_scope

  # Pharma compliance: Audit log every action
  around_action :log_pharma_audit

private

def protect_from_forgery
  super(prepend: true, with: :exception)
end

# ... rest of methods ...

def log_pharma_audit
  Rails.logger.tagged("tenant:#{current_tenant&.id}", "user:#{current_user&.id}") do
    yield
  end
end

# NO protect_from_forgery here!
