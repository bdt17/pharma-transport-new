# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  # Health endpoint
  def health
    head :ok
  end

  # Current tenant (multi‑tenant hook)
  def current_tenant
    # Example: Tenant by subdomain
    # @current_tenant ||= Tenant.find_by(subdomain: request.subdomain)
    #
    # If you’re still single‑tenant in dev, you can stub:
    Tenant.first
  end

  # Current tenant shortcut helper
  helper_method :current_tenant

  # Current user (Devise)
  def current_user
    @current_user ||= super
  end

  helper_method :current_user

  # Tenant scope shortcut you can use in controllers
  def current_tenant_scope
    Batch.where(tenant: current_tenant) if current_tenant
  end

  protect_from_forgery with: :exception
end
