class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def index
    @batches = Batch.where(tenant: current_tenant)
  end

  def tenant_index
    @batches = Batch.where(tenant: current_tenant)
  end
end
skip_before_action :authenticate_user!, only: :index
def index
end
