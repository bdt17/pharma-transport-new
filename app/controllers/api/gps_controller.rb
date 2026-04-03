class Api::GpsController < ApplicationController
  # Remove if you want it public instead of protected
  # before_action :authenticate_user!

  def index
    render json: { message: "GPS API is OK" }, status: :ok
  end

  def show
    render json: {
      message: "GPS for ID: #{params[:id]} received",
      id: params[:id]
    }, status: :ok
  end
end
