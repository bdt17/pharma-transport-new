class TenantsController < ApplicationController
  before_action :authenticate_user!

  def index
    # Admin tenants list; adjust later
  end
end
