class DashboardController < ApplicationController
  def index
    @recent_payments = []  # Stripe payments
    @active_batches = []   # FDA pharma batches
    @vehicles_online = []  # GPS truck tracking
    render layout: 'dashboard'
  end
end
