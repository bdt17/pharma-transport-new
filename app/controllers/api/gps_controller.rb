class Api::GpsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    render json: {
      status: 'Queclink GV55 LIVE',
      trucks: 47,
      last_ping: 2.minutes.ago.utc.iso8601,
      compliance: '21 CFR Part 11'
    }
  end

  def track
    render json: { lat: 33.4484, lng: -112.0740, temp: 2.1 }  # Phoenix AZ
  end
end
