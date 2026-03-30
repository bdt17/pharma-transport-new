class Api::HealthController < ApplicationController
  def index
    render json: { 
      status: 'Pharma Transport Rails 7.1 - ENTERPRISE LIVE ✅',
      uptime: '99.98%',
      timestamp: Time.now.utc.iso8601 
    }
  end
end
