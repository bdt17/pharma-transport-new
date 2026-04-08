class ApplicationController < ActionController::Base
  # Devise: Redirect after login
  def after_sign_in_path_for(resource)
    dashboard_path
  end

  # Health endpoint (Render.com)
  def health
    head :ok
  end

  # Multi-tenant: Current tenant (subdomain/account)
  def current_tenant
    @current_tenant ||= Tenant.first || Tenant.create!(name: 'Thomas IT Demo', subdomain: 'demo')
  end
  helper_method :current_tenant

  # ... other public methods ...

  # SINGLE private section
  private

  def protect_from_forgery
    super(prepend: true, with: :exception)
  end

  def current_user
    @current_user ||= super
  end
  helper_method :current_user

  def current_tenant_scope
    if current_tenant
      { tenant: current_tenant }
    else
      {}
    end
  end
  helper_method :current_tenant_scope

  def log_pharma_audit
    Rails.logger.tagged("tenant:#{current_tenant&.id}", "user:#{current_user&.id}") do
      yield
    end
  end

  around_action :log_pharma_audit
end
