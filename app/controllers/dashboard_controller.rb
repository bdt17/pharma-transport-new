class DashboardController < ApplicationController
  def index
    @recent_payments = [] # Add Stripe API logic later
    @recent_batches = []   # Add Batch model later
    @active_vehicles = []  # Add Vehicle model later
  end
end
