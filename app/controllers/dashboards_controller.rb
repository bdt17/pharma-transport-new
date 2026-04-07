class DashboardsController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, only: :index  # ✅ Now works for index

  def index
    @batches = Batch.where(tenant: current_tenant)
  end

  def tenant_index
    @batches = Batch.where(tenant: current_tenant)
  end
end
