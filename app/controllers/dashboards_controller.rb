class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def index
    @batches = Batch.where(tenant: current_tenant)
  end

  def tenant_index
    @batches = Batch.where(tenant: current_tenant)
  end
end
