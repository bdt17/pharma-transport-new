class HomeController < ApplicationController
  before_action :require_login, except: [:index, :pdf_health]
  
  def index
    if session[:logged_in]
      # Production dashboard
    else
      redirect_to login_path, alert: "🔐 Please log in"
    end
  end
  
  def pdf_health
    # Public health check endpoint
    render plain: "PDF Service: OK", status: :ok
  end
  
  private
  
  def require_login
    unless session[:logged_in]
      redirect_to login_path, alert: "🔐 Please log in to access dashboard"
    end
  end
end
